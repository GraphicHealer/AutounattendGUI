# Dynamically find the drive containing the OSDCloud folder
$OSDDrive = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    if (Test-Path "$($_.Root)OSDCloud\Automate") {
        $_.Root
    }
} | Select-Object -First 1

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -AssemblyName System.Drawing

$script:Form = New-Object -TypeName system.Windows.Forms.Form -Property @{
    AutoSize      = $true
    AutoSizeMode  = 'GrowAndShrink'
    ControlBox    = $false
    Font          = 'Microsoft Sans Serif,12'
    StartPosition = 'CenterScreen'
    TopMost       = $true
}

[System.Collections.ArrayList]$MessageArray = @(
    "Internet Connection Failed!`n`nPlease plug in Ethernet or a USB Wifi Device and Click 'Retry Connection'."
)

$Layout = New-Object -TypeName System.Windows.Forms.FlowLayoutPanel -Property @{ AutoSize = $true; Padding = '10,10,10,10'; FlowDirection = 'TopDown' }

$Message = New-Object -TypeName System.Windows.Forms.Label -Property @{ AutoSize = $true; Dock = 'Top' }
$Layout.Controls.Add($Message)

$Manual = New-Object -TypeName System.Windows.Forms.Button -Property @{ AutoSize = $true; Text = 'Retry Connection'; DialogResult = 'OK'; Dock = 'Top' }
$Manual.Add_Click({ $Script:Command = { Initialize-OSDCloudStartnet -WirelessConnect } })

if (Test-Path -Path "$PSScriptRoot\WifiProfile.xml") {
    $MessageArray.Add("`nIf you would like to manually enter WiFi credentials, Click 'Enter Wifi Credentials'.")
    $Manual.text = 'Enter WiFi Credentials'

    $Retry = New-Object -TypeName System.Windows.Forms.Button -Property @{ AutoSize = $true; Text = 'Retry Connection'; DialogResult = 'OK'; Dock = 'Top' }
    $Retry.Add_Click({ $Script:Command = { Initialize-OSDCloudStartnet -WifiProfile } })
    $Layout.Controls.Add($Retry)
}

if (Test-Path -Path "$OSDDrive\OSDCloud\OS\*.wim") {
    $MessageArray.Add("`nIf you would like to install the OS offline, Click 'Offline Install'.")
    $Offline = New-Object -TypeName System.Windows.Forms.Button -Property @{ AutoSize = $true; Text = 'Offline Install'; DialogResult = 'OK'; Dock = 'Top' }
    $Offline.Add_Click({ $Script:Command = { [Environment]::SetEnvironmentVariable('OSDCloudOffline', '1', 'Machine') } })
    $Layout.Controls.Add($Offline)
}

$MessageArray.Add("`nIf you would like to Quit and Reboot, Click 'Quit'.")
$Message.text = ($MessageArray -join '')

$Quit = New-Object -TypeName System.Windows.Forms.Button -Property @{ AutoSize = $true; Text = 'Quit'; DialogResult = 'OK'; Dock = 'Top' }
$Quit.Add_Click({
        $Script:Command = {
            [System.Windows.Forms.MessageBox]::Show('Installation Aborted', 'No Internet', 'OK', 'Error')
            Restart-Computer -Force
            break
        }
    })

$Layout.controls.AddRange(@($Manual, $Quit))

$script:Form.controls.Add($Layout)

while ((Test-Connection -Server '1.1.1.1' -Count 1 -Delay 1 -Quiet -ErrorAction SilentlyContinue) -ne $true) {
    $Script:Command = {}
    [void]$script:Form.ShowDialog()

    & $Script:Command
}
