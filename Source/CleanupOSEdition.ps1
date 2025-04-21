# Dynamically find the drive containing the OSDCloud folder
$OSDDrive = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    if (Test-Path "$($_.Root)OSDCloud\Automate") {
        $_.Root
    }
} | Select-Object -First 1

Move-Item -Path "$OSDDrive\OSDCloud\Automate\Start-OSDCloudGUI.json.bak" -Destination "$OSDDrive\OSDCloud\Automate\Start-OSDCloudGUI.json" -Force -ErrorAction 'SilentlyContinue'
