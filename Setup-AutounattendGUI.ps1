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
    [switch]$NoUpdateConfig,
    [switch]$NoClean
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

$ConfigJSON = [PSCustomObject]@{
    Brand           = $Brand
    DriverHWID      = $DriverHWID
    OutPath         = $OutPath
    WimName         = $WimName
    WorkspacePath   = $WorkspacePath
    AutounattendXML = $AutounattendXML
    GUI_JSON        = $GUI_JSON
    Language        = $Language
}

if (!(Test-Path -Path $WorkspacePath -ErrorAction SilentlyContinue)) {
    New-Item -Path $WorkspacePath -ItemType Directory -Force -ErrorAction 'Stop' | Out-Null
}

if (!(Test-Path -Path $OutPath -ErrorAction SilentlyContinue)) {
    New-Item -Path $OutPath -ItemType Directory -Force -ErrorAction 'Stop' | Out-Null
}

if (!(Test-Path -Path "$OutPath\OSDCloud" -ErrorAction SilentlyContinue)) {
    New-Item -Path "$OutPath\OSDCloud" -ItemType Directory -Force -ErrorAction 'Stop' | Out-Null
}

if (!(Test-Path -Path "$OutPath\OSDCloud\Automate" -ErrorAction SilentlyContinue)) {
    New-Item -Path "$OutPath\OSDCloud\Automate" -ItemType Directory -Force -ErrorAction 'Stop' | Out-Null
}

if (!(Test-Path -Path "$OutPath\OSDCloud\OS" -ErrorAction SilentlyContinue)) {
    New-Item -Path "$OutPath\OSDCloud\OS" -ItemType Directory -Force -ErrorAction 'Stop' | Out-Null
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

# Install the OSD module
Write-Output 'Installing the OSD module...'
Install-Module OSD -Force

# Create the OSDCloud template
Write-Output 'Creating the OSDCloud Template...'
if (!((Set-OSDCloudTemplate -Name 'AutounattendGUI') -match 'AutounattendGUI') -or !(Test-Path -Path "$(Get-OSDCloudWorkspace)\Media\$Language")) {
    if ($Language -match 'en-us') {
        New-OSDCloudTemplate -Name 'AutounattendGUI' -WinRE
    } else {
        New-OSDCloudTemplate -Name 'AutounattendGUI' -WinRE -Language $Language -SetAllIntl $Language
    }
}

# Clean the Previous Workspace
if (!$NoClean) {
    Get-ChildItem $WorkspacePath | Remove-Item -Recurse -Force -ErrorAction 'Continue'
}

# Create the OSDCloud workspace
Write-Output 'Creating the OSDCloud Workspace...'
New-OSDCloudWorkspace -WorkspacePath $WorkspacePath

# Remove unnecessary files
Write-Output 'Removing unnecessary files...'
$KeepTheseDirs = @('boot', 'efi', $Language, 'en-us', 'sources', 'fonts', 'resources')
Get-ChildItem "$(Get-OSDCloudWorkspace)\Media" | Where-Object { $_.PSIsContainer } | Where-Object { $_.Name -notin $KeepTheseDirs } | Remove-Item -Recurse -Force
Get-ChildItem "$(Get-OSDCloudWorkspace)\Media\Boot" | Where-Object { $_.PSIsContainer } | Where-Object { $_.Name -notin $KeepTheseDirs } | Remove-Item -Recurse -Force
Get-ChildItem "$(Get-OSDCloudWorkspace)\Media\EFI\Microsoft\Boot" | Where-Object { $_.PSIsContainer } | Where-Object { $_.Name -notin $KeepTheseDirs } | Remove-Item -Recurse -Force

# Copy Profile.ps1
Write-Output 'Copying Profile.ps1...'
Copy-Item -Path "$PSScriptRoot\Source\Profile.ps1" -Destination "$(Get-OSDCloudWorkspace)\Config\Scripts\Profile.ps1" -Force -ErrorAction 'Stop'

# Copy CheckNet.ps1
Write-Output 'Copying CheckNet.ps1...'
Copy-Item -Path "$PSScriptRoot\Source\CheckNet.ps1" -Destination "$(Get-OSDCloudWorkspace)\Config\Scripts\CheckNet.ps1" -Force -ErrorAction 'Stop'

# Copy GetOSEdition.ps1
Write-Output 'Copying GetOSEdition.ps1...'
Copy-Item -Path "$PSScriptRoot\Source\GetOSEdition.ps1" -Destination "$(Get-OSDCloudWorkspace)\Config\Scripts\GetOSEdition.ps1" -Force -ErrorAction 'Stop'

# Copy CleanupOSEdition.ps1
Write-Output 'Copying CleanupOSEdition.ps1...'
Copy-Item -Path "$PSScriptRoot\Source\CleanupOSEdition.ps1" -Destination "$(Get-OSDCloudWorkspace)\Config\Scripts\Startup\CleanupOSEdition.ps1" -Force -ErrorAction 'Stop'

# Copy Autounattend.ps1
Write-Output 'Copying Autounattend.ps1...'
Copy-Item -Path "$PSScriptRoot\Source\Autounattend.ps1" -Destination "$(Get-OSDCloudWorkspace)\Config\Scripts\Shutdown\Autounattend.ps1" -Force -ErrorAction 'Stop'

# Complete
$originalColor = $host.UI.RawUI.ForegroundColor
$host.UI.RawUI.ForegroundColor = 'Green'
Write-Output "`n`nOSDCloud-Setup complete!`nPlease run the Build-AutounattendGUI.ps1 script to generate the OSDCloud image.`n"
$host.UI.RawUI.ForegroundColor = 'Yellow'
Read-Host -Prompt 'Press Enter to exit...'
$host.UI.RawUI.ForegroundColor = $originalColor
