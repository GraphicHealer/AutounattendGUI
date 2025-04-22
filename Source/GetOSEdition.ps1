# Dynamically find the drive containing the OSDCloud folder
$OSDDrive = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    if (Test-Path "$($_.Root)OSDCloud\Automate") {
        $_.Root
    }
} | Select-Object -First 1

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

$Hash = @{
    'Home'       = 4
    'Pro'        = 9
    'Enterprise' = 6
}

try {
    reg load 'HKU\SystemRoot' 'C:\Windows\System32\config\SOFTWARE'
    $Edition = (Get-ItemProperty 'Registry::HKEY_USERS\SystemRoot\Microsoft\Windows NT\CurrentVersion').EditionID
    [gc]::Collect()
    reg unload 'HKU\SystemRoot'
} catch {
    $Edition = 'Professional'
}
$OSDCloudJSON = Get-Content -Path "$OSDDrive\OSDCloud\Automate\Start-OSDCloudGUI.json" | ConvertFrom-Json
$OldEdition = $OSDCloudJSON.OSEdition

if ($Edition -match 'Professional') { $Edition = 'Pro' }
if ($Edition -match 'Core') { $Edition = 'Home' }

Write-Output "Edition: $Edition, OldEdition: $OldEdition"

if (($Edition -ne $OldEdition) -and $Edition -ne $null) {
    $OSDCloudJSON.OSEdition = $Edition
    $OSDCloudJSON.OSImageIndex = $Hash[$Edition]

    Copy-Item -Path "$OSDDrive\OSDCloud\Automate\Start-OSDCloudGUI.json" -Destination "$OSDDrive\OSDCloud\Automate\Start-OSDCloudGUI.json.bak" -Force
    $OSDCloudJSON | ConvertTo-Json -Depth 10 | Format-Json | Set-Content -Path "$OSDDrive\OSDCloud\Automate\Start-OSDCloudGUI.json" -Force
}
