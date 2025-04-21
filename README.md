# OSD-AutounattendGUI
This is my particular OSDCloud setup, built into easy-to-deploy setup and build scripts.
This is designed to be used with Ventoy, the bootable flashdrive swiss army kinfe.

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

## Running
**THIS MUST BE RUN ON WINDOWS 10**
There is a bug in the windows 11 version of WinPE that does not allow Wifi drivers to fuinction properly through OSDCloud.
Please use Windows 10 for your build environment, you can use a VM or a dedicated machine.

First, download the Git repo.
Run the following in an Administrator Powershell:
```powershell
git clone https://github.com/GraphicHealer/AutounattendGUI.git
cd .\AutounattendGUI\
```
Leave the powershell window open, you will need it later.

Next, follow these instructions from OSDCloud and install the ADK and ADK-WinPE installers:
https://www.osdcloud.com/osdcloud/setup

Next, open `Settings.json` in your favorite text editor (I reccomend Notepad++).
This is what you will see:
```json
{
    "AutounattendXML": ".\\Build-Files\\Autounattend.xml",
    "Brand": "AutounattendGUI",
    "DriverHWID": [
        "VID_2357&PID_011E",
        "VID_17E9&PID_4307"
    ],
    "GUI_JSON": ".\\Build-Files\\Start-OSDCloudGUI.json",
    "OutPath": ".\\Ventoy-Drive",
    "WallpaperPath": ".\\Build-Files\\Wallpaper.jpg",
    "WimName": "1_AutounattendGUI.wim",
    "WorkspacePath": ".\\AuGUI-Workspace"
}
```

You will want to change some of the paths. For example:
```json
{
    "AutounattendXML": ".\\MyOrgName\\Autounattend.xml",
    "Brand": "MyOrgName",
    "DriverHWID": [
        "VID_2357&PID_011E",
        "VID_17E9&PID_4307"
    ],
    "GUI_JSON": ".\\MyOrgName\\Start-OSDCloudGUI.json",
    "OutPath": ".\\MyOrgName\\Ventoy-Drive",
    "WallpaperPath": ".\\MyOrgName\\Wallpaper.jpg",
    "WimName": "1_AutounattendGUI.wim",
    "WorkspacePath": ".\\MyOrgName\\AuGUI-Workspace"
}
```
