param(
    [string]$WorkspacePath,
    [string]$OutPath,
    [string]$WimName,
    [string]$ConfigFile = '.\Settings.json',
    [string]$WifiProfilePath,
    [string]$WallpaperPath,
    [string]$Brand,
    [System.Collections.ArrayList]$DriverHWID,
    [string]$AutounattendXML,
    [string]$GUI_JSON,
    [string]$Language,
    [string]$Mode,
    [switch]$NoUpdateConfig
)

# Formats JSON in a nicer format than the built-in ConvertTo-Json does.
function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
    $indent = 0
    ($json -Split "`n" | ForEach-Object {
        if ($_ -match '[\}\]]\s*,?\s*$') { $indent-- }
        $line = ('  ' * $indent) + $($_.TrimStart() -replace '":  (["{[])', '": $1' -replace ':  ', ': ')
        if ($_ -match '[\{\[]\s*$') { $indent++ }
        $line
    }) -Join "`n"
}

# Get Settings.json
if (Test-Path -Path $ConfigFile -ErrorAction SilentlyContinue) {
    $jsonContent = Get-Content -Path $ConfigFile -Raw
    $ConfigJSON = ConvertFrom-Json -InputObject $jsonContent

    if (!$WorkspacePath) { $WorkspacePath = $ConfigJSON.WorkspacePath }
    if (!$OutPath) { $OutPath = $ConfigJSON.OutPath }
    if (!$WifiProfilePath) { $WifiProfilePath = $ConfigJSON.WifiProfilePath }
    if (!$WallpaperPath) { $WallpaperPath = $ConfigJSON.WallpaperPath }
    if (!$Brand) { $Brand = $ConfigJSON.Brand }
    if (!$DriverHWID) { $DriverHWID = $ConfigJSON.DriverHWID }
    if (!$WimName) { $WimName = $ConfigJSON.WimName }
    if (!$AutounattendXML) { $AutounattendXML = $ConfigJSON.AutounattendXML }
    if (!$GUI_JSON) { $GUI_JSON = $ConfigJSON.GUI_JSON }
    if (!$Language) { $Language = $ConfigJSON.Language }
    if (!$Mode) { $Mode = $ConfigJSON.Mode }
    
    if (!$ConfigJSON.WorkspacePath -or !$ConfigJSON.OutPath) { $NoUpdateConfig = $false }
}

# Verify parameters
if (!$WorkspacePath) { $WorkspacePath = '.\AuGUI-Workspace' }
if (!$OutPath) { $OutPath = '.\Ventoy-Drive' }
if (!$WimName) { $WimName = '1_AutounattendGUI.wim' }
if (!$WifiProfilePath) { $WifiProfilePath = $null }
if (!$Brand) { $Brand = 'AutounattendGUI' }
if (!$AutounattendXML) { $AutounattendXML = '.\Build-Files\Autounattend.xml' }
if (!$GUI_JSON) { $GUI_JSON = '.\Build-Files\Start-OSDCloudGUI.json' }
if (!$Language) { $Language = 'en-us' }
if (!$Mode) { $Mode = 'Drive' }

$ConfigJSON = [PSCustomObject]@{
    Brand           = $Brand
    DriverHWID      = $DriverHWID
    OutPath         = $OutPath
    WimName         = $WimName
    WorkspacePath   = $WorkspacePath
    AutounattendXML = $AutounattendXML
    GUI_JSON        = $GUI_JSON
    Language        = $Language
    Mode            = $Mode
}

if ($WifiProfilePath) {
    if (!(Test-Path -Path $WifiProfilePath -ErrorAction SilentlyContinue)) {
        Write-Error "WifiProfilePath: '$WifiProfilePath' does not exist!"
        exit 1
    } else {
        $ConfigJSON | Add-Member -MemberType NoteProperty -Name 'WifiProfilePath' -Value $WifiProfilePath
    }
}

if ($WallpaperPath) {
    if (!(Test-Path -Path $WallpaperPath -ErrorAction SilentlyContinue)) {
        Write-Error "WallpaperPath: '$WallpaperPath' does not exist!"
        exit 1
    } else {
        $ConfigJSON | Add-Member -MemberType NoteProperty -Name 'WallpaperPath' -Value $WallpaperPath
    }
}

Write-Output 'Using the following Config:'
Write-Output $ConfigJSON

# Update Settings.json
if (!$NoUpdateConfig) {
    New-Item -Path $ConfigFile -Force -ErrorAction 'Stop' | Out-Null
    Set-Content -Path $ConfigFile -Value ($ConfigJSON | ConvertTo-Json -Depth 10 | Format-Json )
    Write-Output "Config saved to '$ConfigFile'"
}

# Copy Autounattend.xml and Start-OSDCloudGUI.json
if ($GUI_JSON) {
    if ((Test-Path -Path $GUI_JSON -ErrorAction SilentlyContinue)) {
        Write-Output 'Copying Start-OSDCloudGUI.json...'
        $GuiJsonContent = (Get-Content -Raw -Path $GUI_JSON -ErrorAction 'Stop')

        if (($GuiJsonContent -match 'AutounatendGUI') -and ($Language -ne 'en-us')) {
            $GuiJsonContent = $GuiJsonContent -replace '"OSLanguage": "en-us",', "`"OSLanguage`": `"$Language`","
            $GuiJsonContent = $GuiJsonContent -replace "(?sm)`"OSLanguageValues`": \[.*?],", "`"OSLanguageValues`": [`n    `"$Language`",`n    `"en-us`"`n  ],"
        }

        $GuiJsonContent = $GuiJsonContent.Clone() -replace 'AutounatendGUI', $Brand

        if ($Mode -match 'AIO') {
            Write-Output 'All-In-One Mode!'
            Set-Content -Path "$(Get-OSDCloudWorkspace)\Config\Scripts\Start-OSDCloudGUI.json" -Force -Value $GuiJsonContent
        } else {
            New-Item -Path "$OutPath\OSDCloud\Automate" -ItemType Directory -Force -ErrorAction 'Stop' | Out-Null
            Set-Content -Path "$OutPath\OSDCloud\Automate\Start-OSDCloudGUI.json" -Force -Value $GuiJsonContent
        }
    }
}

if ($AutounattendXML) {
    if ((Test-Path -Path $AutounattendXML -ErrorAction SilentlyContinue)) {
        Write-Output 'Copying Autounattend.xml...'
        if ($Mode -match 'AIO') {
            Write-Output 'All-In-One Mode!'
            Copy-Item -Path $AutounattendXML -Destination "$(Get-OSDCloudWorkspace)\Config\Scripts\Autounattend.xml" -Force -ErrorAction 'Stop'
        } else {
            New-Item -Path "$OutPath\OSDCloud\Automate" -ItemType Directory -Force -ErrorAction 'Stop' | Out-Null
            Copy-Item -Path $AutounattendXML -Destination "$OutPath\OSDCloud\Automate\Autounattend.xml" -Force -ErrorAction 'Stop'
        }
    }
}

# Set Workspace
Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath

# Generate the OSDCloud image
Write-Output 'Generating the OSDCloud image...'
$WinPEParameters = @{
    CloudDriver      = '*'
    DriverHWID       = $DriverHWID
    Wallpaper        = $WallpaperPath
    StartPSCommand   = 'Copy-Item -Path "X:\OSDCloud\Config\Scripts\Profile.ps1" -Destination "$PSHOME\Profile.ps1" -Force; & "X:\OSDCloud\Config\Scripts\CheckNet.ps1"; & X:\OSDCloud\Config\Scripts\GetOSEdition.ps1'
    StartOSDCloudGUI = $true
    Brand            = $Brand
    WirelessConnect  = (!$WifiProfilePath)
}

if ($WifiProfilePath) {
    $WinPEParameters.Add('WifiProfile', $WifiProfilePath)
}

Edit-OSDCloudWinPE @WinPEParameters

# Copy the boot.wim to the ISO's folder
Write-Output "Copying boot.wim to the ISO's folder..."
New-Item -Path $OutPath -ItemType Directory -Force -ErrorAction 'Stop' | Out-Null
Copy-Item -Path "$(Get-OSDCloudWorkspace)\Media\sources\boot.wim" -Destination "$OutPath\$WimName" -Force -ErrorAction 'Stop'

# Complete
$originalColor = $host.UI.RawUI.ForegroundColor
$host.UI.RawUI.ForegroundColor = 'Green'
Write-Output "`n`nOSDCloud image has been generated successfully!`nPlease copy the files in '$OutPath' to your Ventoy FlashDrive."
$host.UI.RawUI.ForegroundColor = 'Yellow'
Read-Host -Prompt 'Press Enter to exit...'
$host.UI.RawUI.ForegroundColor = $originalColor
