# OSD-AutounattendGUI
This is my particular OSDCloud setup, built into easy-to-deploy setup and build scripts.

> [!WARNING]
> **This is designed to be used with Ventoy, the bootable flash drive swiss army knife. Please have a Ventoy flash drive prepared.**

- https://www.osdcloud.com
- https://www.ventoy.net

Special thanks to the NinjaOne Community, some of the script functions and techniques are from the awesome people over there who were oh-so-patient with me learning PowerShell over the last year or so!


## Table of Contents
1. [Building an Image](#building-an-image)
   1. [Getting Started](#getting-started)
   2. [Setup](#setup)
   3. [Prepare Files](#prepare-files)
   4. [Build](#build)
   5. [Custom/Existing Ventoy Setup](#customexisting-ventoy-setup)
2. [Usage](#usage)
3. [Troubleshooting](#troubleshooting)

<hr />

# Building an Image
## Getting started
> [!IMPORTANT]
> Please read through this entire README before starting. This helps cut down on confusion and misunderstanding.

The two main scripts are as follows:
1. Setup-autounattendGUI.ps1: The Setup Script, for preparing the Build environment.
2. Build-AutounattendGUI.ps1: This is the script to run when you need to build/update the .wim file.

Both scripts will pull their runtime settings from `Settings.json`, or a `.json` config specified with the `-ConfigFile` flag.
An example config is provided, but you can also generate one by inputting the values directly into one of the scripts using their flags:
- `-WorkspacePath`: The Path to where you want OSDCloud to build its Workspace
- `-OutPath`: The path to save output files to
- `-WimName`: What to name the completed `.wim` file
- `-WifiProfilePath`: (Optional) Path to valid windows Wi-Fi Profile XML
- `-WallpaperPath`: (Optional) Path to Windows PE Wallpaper
- `-Brand`: Brand name to use on Start-OSDCloudGUI
- `-DriverHWID`: (Optional) Array of valid HWID strings to add extra drivers
- `-AutounattendXML`: Path to valid Autounattend.xml file, to be copied to OS after Install
- `-GUI_JSON`: Path to Valid Start-OSDCloudGUI.json
- `-Language`: The language code you want to use for OSDCloud (Eg: `en-us` or `de-de`).
- `-NoUpdateConfig`: Disable updating/creating Settings.json (-ConfigPath), useful for testing without overwriting the config.

## Setup
> [!CAUTION]
> **!!!THIS MUST BE RUN ON WINDOWS 10!!!**
>
> The windows 11 version of WinPE does not allow Wi-Fi and other drivers to function properly through OSDCloud, as it drops support for several key devices.
Please use Windows 10 for your build environment, you can use a VM or a dedicated machine.

> [!WARNING]
> You must have Windows 10 version 2004 (April 2020) or newer, you can check the version in `Settings > System > About`, as shown here:
> <br />
> ![image](https://github.com/user-attachments/assets/f289fe4b-c21b-4142-81a9-68bb6caea814)
> 
> I used the latest Windows 10 22H2.

First, install ADK and ADK-WinPE:
1. Go to https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install
2. **MAKE SURE** to use **THIS** version of ADK and ADK-WinPE (Download both):
   <br />
   ![image](https://github.com/user-attachments/assets/3f66c7d2-57ad-4a60-8202-e11ff868e994)
3. Run the ADK installer first (Not ADK-WinPE). Just use the defaults till you get to the step shown below.
4. When you get to this screen, only select the option highlighted below:
   <br />
   ![image](https://github.com/user-attachments/assets/4253d03f-c51f-4375-8604-aab8ad1868e0)
5. Just use defaults for the rest of the installation.
6. Once the ADK is finished installing, run ADK-WinPE. Just keep all the defaults and keep pressing next.
7. Done!

Now, download the Git repo.
Run the following in an Administrator PowerShell:
```powershell
git clone https://github.com/GraphicHealer/AutounattendGUI.git
cd .\AutounattendGUI\
```
Leave the powershell window open, you will need it later.

Next, open a copy of `Settings.json` in your favorite text editor (I recommend Notepad++).
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
    "Language": "en-us",
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
    "Language": "en-us",
    "OutPath": ".\\MyOrgName\\Ventoy-Drive",
    "WallpaperPath": ".\\Build-Files\\Wallpaper.jpg",
    "WimName": "1_AutounattendGUI.wim",
    "WorkspacePath": ".\\MyOrgName\\AuGUI-Workspace"
}
```
Note how `MyOrgName` has been added to some of the paths, this will help you keep different builds separated.

Save it under a new name, like `MyOrgName-Settings.json`

Once you have `MyOrgName-Settings.json` setup, switch back to the Admin Powershell you left open, and run the following:
```powershell
Set-ExecutionPolicy Bypass # Set this so you can run the setup and build scripts
.\Setup-AutounattendGUI.ps1 -ConfigFile .\MyOrgName-Settings.json
```
This will run through and set up the Build Environment, getting it ready.

## Prepare Files
Next, create or find your `Autounattend.xml` file (I used this site to build one: https://schneegans.de/windows/unattend-generator/), and copy it to where your `MyOrgName-Settings.json` points to (`.\\MyOrgName\\Autounattend.xml` in this example).

Then, you need to copy the file at `.\Build-Files\Start-OSDCloudGUI.json` to where your `MyOrgName-Settings.json` points (`.\\MyOrgName\\Start-OSDCloudGUI.json` in this example).

Edit the file accordingly, using this tutorial: https://www.osdcloud.com/osdcloud-automate/osdcloudgui-defaults

If you set a custom wallpaper path, just make sure it's a `.jpg` file, and copy it to where your `MyOrgName-Settings.json` points.

## Build
Once the `Setup-AutounattendGUI.ps1` has been run and the build files are in place, you can now build the image!

Go back to the Admin Powershell window you have open, and run the following:
```powershell
.\Build-AutounattendGUI.ps1 -ConfigFile .\MyOrgName-Settings.json
```

## Install
### New Ventoy Drive
When the script is done, it should tell you to copy the contents of `OutPath` (`.\\MyOrgName\\Ventoy-Drive` in this example) to the root of your Ventoy flash drive (E.g.: `D:\`).

> [!WARNING]
> You will need to have the wimboot mode setup on your Ventoy drive, follow this page to set it up: https://www.ventoy.net/en/plugin_wimboot.html

Here is the expected Folder Structure:
```
D:\
  |- ventoy\
  |   |- ventoy.json
  |   '- ventoy_wimboot.img
  |- OSDCloud\
  |   |- Automate\
  |   |   |- autounattend.xml
  |   |   '- Start-OSDCloudGUI.json
  |   '- OS\
  '- 1_AutounattendGUI.wim
```

### Custom/Existing Ventoy Setup
> [!CAUTION]
> This section is ONLY applicable if you already have an existing Ventoy setup.
1. **MAKE SURE** the entire `OSDCloud\` folder in the Output folder is copied to the **ROOT** of your Ventoy drive's storage partition (E.g.: `D:\OSDCloud\`).
3. **DO NOT** copy the `ventoy` folder in the `OutPath` **IF** you already have a custom `ventoy.json` setup. *It will overwrite that if you do.*
4. If you do have a custom `ventoy.json`, look at this file for the relevant configuration you may want to add: [ventoy.json](Ventoy-Drive/ventoy/ventoy.json)

<hr />

# Usage

### Internet
When you boot the .wim file, it will load the system and start preparing OSDCloud.
If it detects that there is no internet connectivity, it will pop this up:

![image](https://github.com/user-attachments/assets/6793b3c6-ba9d-4902-a0b7-f8e3e13b3656)

You can choose the option that works best for you.
- `Enter Wifi Credentials` will only appear when you have set `WifiProfilePath` in the build settings.
- `Offline Install` will only show when you have included a Windows `install.wim` in the
`OSDCloud\OS\` folder on your flash drive (this is sometimes useful for on-the-go deployment).

### GUI
Now with working internet, the next page that shows is the OSDCloudGUI. Here you can choose whatever Edition, Language, and Driver Pack you wish.

![image](https://github.com/user-attachments/assets/a1b94807-7f9d-4038-b0bb-cbf5e159d8cc)

If a non-BitLocker `C:` drive with an existing windows install is present on the system, AutounattendGUI's Edition Select script will select the same edition currently present on the `C:` drive (Unless you are using an Offline installer).

With everything selected, click "Start"!

### Confirmation
The script will then ask you if the drive it's detected to install Windows on is valid.

![CeqRGrxJfbpWo6r0LAbE_](https://github.com/user-attachments/assets/79297cdd-5c73-4ad8-b0c2-c64fd157d467)

if it is, reply `Y` to the prompt and hit `Enter`.

Now OSDCloud, the setup scripts, and Autounattend.xml will do their magic!

In a short time, you will have a fully functioning Windows installation on your PC!

<hr />

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

Once you have replaced the file, OSDCloudGUI should run properly again.
