# OSD-AutounattendGUI
This is my particular OSDCloud setup, built into easy-to-deploy setup and build scripts.

## Getting started
The two main scripts are as follows:
1. Setup-autounattendGUI.ps1: The Setup Script, for preparing the Build environment.
2. Build-AutounattendGUI.ps1: This is the script to run when you need to build/update the .wim file.

Both scripts will pull their runtime settings from `Settings.json`, or a .json config specified with the `-ConfigFile` flag.
An example config is provided, but you can also generate one by inputting the values directly into one of the scripts using their flags:
- `-WorkspacePath`: The Path to where you want OSDCloud to build it's Workspace
- `-OutPath`: The path to save output files to
- `-WimName`: What to name the completed .wim file
- `-WifiProfilePath`: (Optional) Path to valid windows Wifi Profile XML
- `-WallpaperPath`: (Optional) Path to Windows PE Wallpaper
- `-Brand`: Brandname to use on Start-OSDCloudGUI
- `-DriverHWID`: (Optional) Array of valid HWID strings to add exrtra drivers
- `-AutounattendXML`: Path to valid Autounattend.xml file, to be copied to OS after Install
- `-GUI_JSON`: Path to Valid Start-OSDCloudGUI.json
- `-NoUpdateConfig`: Disable updating/creating Settings.json (-ConfigPath), usefull for testing without loosing config.
