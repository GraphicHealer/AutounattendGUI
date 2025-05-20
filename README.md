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

Next, follow these instructions from OSDCloud to install OSD, ADK, and ADK-WinPE:
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
Note how `MyOrgName` has been added to some of the paths, this will help you keep different builds seperated.

Save it under a new name, like `MyOrgName-Settings.json`

Once you have `MyOrgName-Settings.json` setup, switch back to the Admin Powershell you left open, and run the following:
```powershell
Set-ExecutionPolicy Bypass # Set this so you can run the setup and build scripts
.\Setup-AutounattendGUI.ps1 -ConfigFile .\MyOrgName-Settings.json
```
This will run through and setup the Build Environment, getting it ready.

## Prepare Files
Next, create or find your `Autounattend.xml` file (I used this site to build one: https://schneegans.de/windows/unattend-generator/), and copy it to where your `MyOrgName-Settings.json` points to (`.\\MyOrgName\\Autounattend.xml` in this example).

Then, you need to copy the file at `.\Build-Files\Start-OSDCloudGUI.json` to where your `MyOrgName-Settings.json` points (`.\\MyOrgName\\Start-OSDCloudGUI.json` in this example).

Edit the file accordingly, using this tutorial: https://www.osdcloud.com/osdcloud-automate/osdcloudgui-defaults

If you set a custom wallpaper path, just make sure it's a `.jpg` file, and copy it to where your `MyOrgName-Settings.json` points.

## Build
Once the `Setup-AutounattendGUI.ps1` has been run and the build files are in place, you can now build the image!

Go back to the Admin Powershell window you had open, and run the following:
```powershell
.\Build-AutounattendGUI.ps1 -ConfigFile .\MyOrgName-Settings.json
```
When the script is done, it should tell you to copy the contents of `OutPath` (`.\\MyOrgName\\Ventoy-Drive` in this example) to the root of your Ventoy Flashdrive (Eg: `D:\`).

> [!WARNING]
> You will need to have the wimboot mode setup on your Ventoy drive, follow this page to set it up: https://www.ventoy.net/en/plugin_wimboot.html

## Custom/Exsisting Ventoy Setup
> [!CAUTION]
> This section is ONLY applicable if you already have an exsisting Ventoy setup.
1. **MAKE SURE** the entire `OSDCloud\` folder in the Output folder is copied to the **ROOT** of your Ventoy drive's storage partition (Eg: `D:\OSDCloud\`).
3. **DO NOT** copy the `ventoy` folder in the `OutPath` **IF** you already have a custom `ventoy.json` setup. *It will overwrite that if you do.*
4. If you do have a custom `ventoy.json`, look at this file for the relevant configuration you may want to add: [ventoy.json](Ventoy-Drive/ventoy/ventoy.json)

# Troubleshooting
If OSDCloudGUI is missing options in its dropdown, you may have a corrupted `Start-OSDCloudGUI.json` file.
The scripts automatically make a backup of `Start-OSDCloudGUI.json` before anything starts, just in case the config is messed up.
The backup is usually automatically restored right before OSDCloud finishes the Windows Install and reboots, but if something fails, it may skip this restoration step.
If you run into problems in WinPE and you reboot or shutdown before OSDCloud finishes, you may need to restore the `Start-OSDCloudGUI.json` backup.
If you need to manually restore the file, do the following:
1. Plug your Ventoy flash drive into a working PC
2. Open `<Ventoy>:\OSDCloud\Automate\`
3. You should see both `Start-OSDCloudGUI.json` and `Start-OSDCloudGUI.json.bak`.
4. Delete `Start-OSDCloudGUI.json`
5. Rename `Start-OSDCloudGUI.json.bak` to `Start-OSDCloudGUI.json`
6. Done!
7. 
Once you have replaced the file, OSDCloudGUI should run properly again.
