# AutounattendGUI

A setup script for OSDCloud that automates its configuration, embeds custom scripts to inject an Autounattend.xml file into the Windows installation, and adds enhancements to the overall OSDCloud deployment process.

> \[!WARNING]
> **This is designed to be used with Ventoy, the bootable flash drive swiss army knife. Please have a Ventoy flash drive prepared.**

* [https://www.osdcloud.com](https://www.osdcloud.com)
* [https://www.ventoy.net](https://www.ventoy.net)

Special thanks to the NinjaOne Community, some of the script functions and techniques are from the awesome people over there who were oh-so-patient with me learning PowerShell over the last year or so!

> \[!IMPORTANT]
> ### **Please read through this entire README before starting. This helps cut down on confusion and misunderstanding.**

## Table of Contents

1. [Build](#build)
   * [Script Options](#script-options)
   * [Setup](#setup)
   * [Prepare Files](#prepare-files)
   * [Build-AutounattendGUI.ps1](#build-autounattendguips1)
2. [Install](#install)
   * [New Ventoy Drive](#new-ventoy-drive)
   * [Custom/Existing Ventoy Setup](#customexisting-ventoy-setup)
4. [Usage](#usage)
5. [Troubleshooting](#troubleshooting)
   * [Missing Menu Options](#missing-menu-options)

<hr />

# Build

## Script Options

The two main scripts are:

1. **Setup-autounattendGUI.ps1** — Prepares the build environment.
2. **Build-AutounattendGUI.ps1** — Builds or updates the `.wim` file.

Both `Setup-AutounattendGUI.ps1` and `Build-AutounattendGUI.ps1` use the same flags. Here is a breakdown of each:

| Flag                      | Description                                                                                                                                             |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-WorkspacePath`          | The full path where OSDCloud will build its workspace and temporary files. This is where the Windows PE environment and necessary scripts are staged.   |
| `-OutPath`                | The path where the completed output files (including the final `.wim`) will be saved. Typically, this is a directory you copy to your Ventoy USB drive. |
| `-WimName`                | Filename (including `.wim` extension) to use for the final Windows Imaging file. This is the file that will be booted by Ventoy.                        |
| `-WifiProfilePath` &nbsp; | (Optional) Path to a valid Windows Wi-Fi profile XML. Used to automatically connect to Wi-Fi from the WinPE environment.                                |
| `-WallpaperPath`          | (Optional) Path to a `.jpg` image that will be used as the background wallpaper in Windows PE.                                                          |
| `-Brand`                  | A custom name or label that is shown in Start-OSDCloudGUI and logs. Typically set to your company or project name.                                      |
| `-DriverHWID`             | (Optional) An array of hardware IDs (e.g., `VID_2357&PID_011E`) that will trigger downloading and injecting specific drivers into the image.            |
| `-AutounattendXML`        | Full path to a valid `Autounattend.xml` file. This file is automatically copied and used during the OS installation process.                            |
| `-GUI_JSON`               | Full path to a customized `Start-OSDCloudGUI.json` file, which sets default values for the OSDCloud GUI options.                                        |
| `-Language`               | Specifies the default language for Windows installation (e.g., `en-us`, `de-de`).                                                                       |
| `-NoUpdateConfig`         | When set, the script will not update or create the `Settings.json` file. Useful for testing temporary changes without overwriting saved configurations. |
| `-ConfigFile`             | (Optional) Path to a custom JSON configuration file containing all the above options. Overrides `Settings.json` if both are present.                    |

Each of these options can be passed directly to the PowerShell scripts or included in your `Settings.json` file for convenience and reusability.

## Setup

> \[!CAUTION]
> **!!!THIS MUST BE RUN ON WINDOWS 10!!!**

> \[!WARNING]
> You must have Windows 10 version 2004 (April 2020) or newer.
> 
> ![image](https://github.com/user-attachments/assets/f289fe4b-c21b-4142-81a9-68bb6caea814)

### ADK
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

### Git

Run this in an Admin PowerShell:

```powershell
git clone https://github.com/GraphicHealer/AutounattendGUI.git
cd .\AutounattendGUI\
```
Leave the powershell window open, you will need it later.

### Settings.json

Create a folder for your build (e.g. `MyOrgName\`), copy `Settings.json` into it, and edit paths like this:

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

> \[!WARNING]
> You must use double backslashes (`\\`) in paths. This is a JSON spec requirement.

### Setup-AutounattendGUI.ps1
Switch back to the Admin Powershell you left open, and run the following:
```powershell
Set-ExecutionPolicy Bypass
.\Setup-AutounattendGUI.ps1 -ConfigFile .\MyOrgName\Settings.json
```

## Prepare Files

* Generate `Autounattend.xml` from [https://schneegans.de/windows/unattend-generator/](https://schneegans.de/windows/unattend-generator/)
* Copy and edit `Start-OSDCloudGUI.json` using [https://www.osdcloud.com/osdcloud-automate/osdcloudgui-defaults](https://www.osdcloud.com/osdcloud-automate/osdcloudgui-defaults)
* If you setup a custom wallpaper, Copy your `.jpg` wallpaper file to the path in `Settings.json`

## Build-AutounattendGUI.ps1
Go back to the Admin Powershell window you have open, and run the following:
```powershell
.\Build-AutounattendGUI.ps1 -ConfigFile .\MyOrgName\Settings.json
```

<hr />

# Install

## New Ventoy Drive

> \[!WARNING]
> You will need to have wimboot mode setup on your Ventoy drive: [https://www.ventoy.net/en/plugin\_wimboot.html](https://www.ventoy.net/en/plugin_wimboot.html)

Copy `OutPath` contents to your Ventoy drive’s root (e.g. `D:\`).

Expected structure:

```powershell
D:\
  |- ventoy\
  |   |- ventoy.json
  |   `- ventoy_wimboot.img
  |- OSDCloud\
  |   |- Automate\
  |   |   |- autounattend.xml
  |   |   `- Start-OSDCloudGUI.json
  |   `- OS\
  `- 1_AutounattendGUI.wim
```

## Custom/Existing Ventoy Setup

> \[!CAUTION]
> Only for users with existing Ventoy setups.

1. Copy only the `OSDCloud\` folder to Ventoy root.
2. **Do not overwrite** `ventoy.json` if customized.
3. Refer to provided `ventoy.json` for merging changes.

<hr />

# Usage

## Internet

If no internet is detected:

![image](https://github.com/user-attachments/assets/6793b3c6-ba9d-4902-a0b7-f8e3e13b3656)

Options:

* `Enter Wifi Credentials` — shows if `WifiProfilePath` is set
* `Offline Install` — shows if `.wim` is available in `OSDCloud\OS\`

## GUI

![image](https://github.com/user-attachments/assets/a1b94807-7f9d-4038-b0bb-cbf5e159d8cc)

Edition selection defaults to current system edition (if not using Offline installer). Click **Start**.

## Confirmation

Confirm installation disk:

![CeqRGrxJfbpWo6r0LAbE\_](https://github.com/user-attachments/assets/79297cdd-5c73-4ad8-b0c2-c64fd157d467)

Enter `Y` to proceed.

Windows will install with your custom Autounattend.xml and GUI settings.

<hr />

# Troubleshooting
## Missing Menu Options
If `Start-OSDCloudGUI.json` becomes corrupted, it can disable some menu options.

To fix it:
1. Plug in your Ventoy drive to a working PC
2. Navigate to `\OSDCloud\Automate\`
3. Delete `Start-OSDCloudGUI.json`
4. Rename `Start-OSDCloudGUI.json.bak` to `Start-OSDCloudGUI.json`

This will restore functionality to OSDCloudGUI.
