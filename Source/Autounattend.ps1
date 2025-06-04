# Dynamically find the drive containing the OSDCloud folder
$OSDDrive = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    if (Test-Path "$($_.Root)OSDCloud\Automate") {
        $_.Root
    }
} | Select-Object -First 1

# Check if the drive was found
if ($OSDDrive) {
    # Define paths
    $CustomUnattend = "$OSDDrive\OSDCloud\Automate\autounattend.xml"  # Path to custom unattend
    $PantherUnattend = 'C:\Windows\Panther\unattend.xml'              # Destination path in Panther folder

    if (Test-Path -Path "$PSScriptRoot\autounattend.xml" -ErrorAction SilentlyContinue) {
        $CustomUnattend = "$PSScriptRoot\autounattend.xml"
    }

    # Check if the custom unattend file exists
    if (Test-Path $CustomUnattend) {
        Write-Output 'Copying custom autounattend.xml to the Windows Panther folder...'

        # Ensure the Panther folder exists
        if (!(Test-Path 'C:\Windows\Panther')) {
            New-Item -Path 'C:\Windows\Panther' -ItemType Directory -Force
        }

        # Copy the custom unattend to the Panther folder
        Copy-Item -Path $CustomUnattend -Destination $PantherUnattend -Force
        Write-Output 'Custom unattend.xml has been placed in the Windows Panther folder successfully.'
    } else {
        Write-Output 'Custom autounattend.xml not found in OSDCloud\Automate folder!'
    }
} else {
    Write-Output 'OSDCloud drive not found!'
}
