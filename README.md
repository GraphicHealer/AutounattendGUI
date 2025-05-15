# OSD-AutounattendGUI
This is my particular OSDCloud setup, built into easy-to-deploy setup and build scripts.

> [!WARNING]
> **This is designed to be used with Ventoy, the bootable flashdrive swiss army knife. Please have a Ventoy flashdrive prepared.**

- https://www.osdcloud.com
- https://www.ventoy.net

Special thanks to the NinjaOne Community, some of the script functions and techniques are from the awesome people over there who were oh-so-patient with me learning PowerShell over the last year or so!

## Getting started
> [!IMPORTANT]
> Please read through this entire README before starting. This helps cut down on confusion and misunderstanding.

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
- `-DriverHWID`: (Optional) Array of valid HWID strings to add extra drivers
- `-AutounattendXML`: Path to valid Autounattend.xml file, to be copied to OS after Install
- `-GUI_JSON`: Path to Valid Start-OSDCloudGUI.json
- `-NoUpdateConfig`: Disable updating/creating Settings.json (-ConfigPath), usefull for testing without overwriting the config.

## Setup
> [!CAUTION]
> **!!!THIS MUST BE RUN ON WINDOWS 10!!!**
> 
> The windows 11 version of WinPE does not allow Wifi and other drivers to function properly through OSDCloud, as it drops support for several key devices.
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
> [!NOTE]
> Follow the screenshots in the above instructions, they show you what options to choose in the Installers.

Next, open a copy of `Settings.json` in your favorite text editor (I reccomend Notepad++).
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
    "WallpaperPath": ".\\Build-Files\\Wallpaper.jpg",
    "WimName": "1_AutounattendGUI.wim",
    "WorkspacePath": ".\\MyOrgName\\AuGUI-Workspace"
}
```
Save it under a new name, like `MyOrgName-Settings.json`

Once you have `MyOrgName-Settings.json` setup, switch back to the Admin Powershell you left open, and run the following:
```powershell
Set-ExecutionPolicy Bypass # Set this so you can run the setup and build scripts
.\Setup-AutounattendGUI.ps1 -ConfigFile .\MyOrgName-Settings.json
```
This will run through and setup the Build Environment, getting it ready.

## Prepare Files
Next, create or find your `Autounattend.xml` file (I used this site to build the example: https://schneegans.de/windows/unattend-generator/), and copy it to where your `MyOrgName-Settings.json` points to (`.\\MyOrgName\\Autounattend.xml` in this example).

Then, you need to copy the file at `.\Build-Files\Start-OSDCloudGUI.json` to where your `MyOrgName-Settings.json` points (`.\\MyOrgName\\Start-OSDCloudGUI.json` in this example).

Edit the file accordingly, using this tutorial: https://www.osdcloud.com/osdcloud-automate/osdcloudgui-defaults

You can also set a custom wallpaper path, just make sure it's a `.jpg` file.

## Build
Once the `Setup-AutounattendGUI.ps1` has been run and the build files are in place, you can now build the image!

Go back to the Admin Powershell window you had open, and run the following:
```powershell
.\Build-AutounattendGUI.ps1 -ConfigFile .\MyOrgName-Settings.json
```

When the script is done, it should tell you to copy the contents of the Output folder to your Ventoy Flashdrive.

**MAKE SURE** the **ENTIRE** `OSDCloud\` folder under the Output folder is copied to the **ROOT** of your Ventoy flashdrive (Eg: `D:\OSDCloud\`), as `Start-OSDCloudGUI` looks for that folder at that location *Specifically*.

You can copy the `.wim` file under the Output folder to wherever you keep your ISOs on your Ventoy drive.
> [!NOTE]
> You will need to have the wimboot mode setup on your Ventoy drive, follow this page to set it up: https://www.ventoy.net/en/plugin_wimboot.html
