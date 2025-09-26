# Uninstall and block ad and bloatware on Windows 11

_Gilbert Francois_

## About

_"I paid for Windows — why is Microsoft stuffing it with ads and junk?"_

Let's remove it, shall we?

## How to run the cleanup script

- Save the scripts below e.g., on Desktop.
- Run the `clean_win11_admin.ps1` in an admin powershell and the `clean_win11_user.ps1` as logged in user.

In Powershell as Administrator:

```sh
Set-ExecutionPolicy Bypass -Scope Process -Force
  "$env:USERPROFILE\Desktop\clean_win11_admin.ps1"
```

In Powershell as user:

```sh
Set-ExecutionPolicy Bypass -Scope Process -Force
  "$env:USERPROFILE\Desktop\clean_win11_user.ps1"
```

- Reboot when it finishes

## Optional manual tweaks

- Settings → Personalization → Start → turn off "Show recommendations."
- Settings → Personalization → Lock screen → change from Windows Spotlight to Picture/Slideshow.

File Explorer → Options → Privacy → uncheck "Show recently used files" and "Show frequently used folders."

## Output...

What it might look like when running the script:

```sh
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

Install the latest PowerShell for new features and improvements! https://aka.ms/PSWindows

PS C:\WINDOWS\system32> cd C:\Users\grumpy\Desktop\
PS C:\Users\grumpy\Desktop> Set-ExecutionPolicy Bypass -Scope Process -Force
PS C:\Users\grumpy\Desktop> . "$env:USERPROFILE\Desktop\clean_win11_admin.ps1"

=== Windows 11 minimalization starting... ===

No matches for *tiktok*
No matches for *candycrush*
No matches for *spotify*
No matches for Microsoft.Clipchamp*
Removing Appx: Microsoft.GamingApp
Removing Appx: Microsoft.XboxGameCallableUI
Removing Appx: Microsoft.Xbox.TCUI
Removing Appx: Microsoft.XboxGamingOverlay
Removing Appx: Microsoft.XboxIdentityProvider
Removing Appx: Microsoft.XboxSpeechToTextOverlay
Removing Appx: Microsoft.MicrosoftSolitaireCollection
No matches for Microsoft.SkypeApp*
Removing Appx: Microsoft.GetHelp
No matches for Microsoft.Getstarted*
No matches for Microsoft.People*
Removing Appx: Microsoft.YourPhone
Removing Appx: Microsoft.BingNews
Removing Appx: Microsoft.BingWeather
Removing Appx: Microsoft.WindowsFeedbackHub
Removing Appx: Microsoft.ZuneMusic
No matches for Microsoft.ZuneVideo*
Removing Appx: Microsoft.MicrosoftOfficeHub
Removing Appx: Microsoft.MicrosoftStickyNotes
No matches for Microsoft.MSPaint*
Removing Appx: Microsoft.PowerAutomateDesktop
Attempting OneDrive removal...
OneDrive uninstalled.
Applying system policies to block reinstallation and ads...
Tuning per-user content/ads settings...
Disabling CEIP/telemetry-related scheduled tasks (harmless to skip if missing)...
Disabled task: \Microsoft\Windows\Customer Experience Improvement Program\Consolidator
Disabled task: \Microsoft\Windows\Customer Experience Improvement Program\UsbCeip
Disabled task: \Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser
ERROR: The specified task name "\Microsoft\Windows\Application Experience\ProgramDataUpdater" does not exist in the system.
Disabled task: \Microsoft\Windows\Application Experience\ProgramDataUpdater
Disabled task: \Microsoft\Windows\Feedback\Siuf\DmClient
Disabled task: \Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload
Disabled task: \Microsoft\Windows\Maps\MapsUpdateTask
Disabled task: \Microsoft\Windows\Windows Error Reporting\QueueReporting
Completed. Some changes require sign out/reboot to fully apply.
Recommendation: Reboot now. If any bundled apps reappear after a Feature Update,
```

## Extra: Install Windows 11 on non-supported machines

When installing from a bootable USB stick, press [shift][F10], start regedit and add
the keys below:

```regedit
HKEY_LOCAL_MACHINE\SYSTEM\Setup\LabConfig
   BypassTPMCheck        (DWORD) = 1
   BypassSecureBootCheck (DWORD) = 1
   BypassRAMCheck        (DWORD) = 1
   BypassCPUCheck        (DWORD) = 1
```
