<#  CleanWin11_Admin.ps1  — System-wide cleanup (RUN AS ADMIN)
    - Removes provisioned & installed Store apps (all users)
    - Uninstalls OneDrive
    - Applies system policies (HKLM) to block consumer experiences/ads
    - Disables CEIP/telemetry-related scheduled tasks
    - NO per-user (HKCU) tweaks included


Run in powershell as admin:

Set-ExecutionPolicy Bypass -Scope Process -Force
. "$env:USERPROFILE\Desktop\clean_win11_admin.ps1"
#>

Write-Host "`n=== Windows 11 ADMIN cleanup starting... ===`n"

# -------------------------------
# Helper: Remove Appx for all users + provisioned (requires admin)
# -------------------------------
function Remove-AppxFull {
    param([string]$Pattern)

    $removed = $false

    # Installed apps (all users)
    Get-AppxPackage -AllUsers | Where-Object { $_.Name -like $Pattern } | ForEach-Object {
        try {
            Write-Host "Removing Appx: $($_.Name)"
            Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
            $removed = $true
        } catch {}
    }

    # Provisioned packages (for new profiles)
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $Pattern } | ForEach-Object {
        try {
            Write-Host "Deprovisioning: $($_.DisplayName)"
            Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
            $removed = $true
        } catch {}
    }

    if (-not $removed) { Write-Host "No matches for $Pattern" }
}

# -------------------------------
# 1) Remove “sponsored” / consumer apps (SAFE LIST; comment out anything you want to keep)
# -------------------------------
$patterns = @(
    "*tiktok*",
    "*candycrush*",
    "*spotify*",
    "Microsoft.Clipchamp*",
    "Microsoft.GamingApp*",
    "Microsoft.Xbox*",
    "Microsoft.MicrosoftSolitaireCollection*",
    "Microsoft.SkypeApp*",
    "Microsoft.GetHelp*",
    "Microsoft.Getstarted*",
    "Microsoft.People*",
    "Microsoft.YourPhone*",
    "Microsoft.BingNews*",
    "Microsoft.BingWeather*",
    "Microsoft.WindowsFeedbackHub*",
    "Microsoft.ZuneMusic*",
    "Microsoft.ZuneVideo*",
    "Microsoft.MicrosoftOfficeHub*",
    "Microsoft.MicrosoftStickyNotes*",
    "Microsoft.PowerAutomateDesktop*"
)

foreach ($p in $patterns) { Remove-AppxFull -Pattern $p }

# -------------------------------
# 2) OneDrive removal (system-wide)
# -------------------------------
Write-Host "Attempting OneDrive removal..."
$oneDriveSetup = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
if (-not (Test-Path $oneDriveSetup)) { $oneDriveSetup = "$env:SystemRoot\System32\OneDriveSetup.exe" }
if (Test-Path $oneDriveSetup) {
    try {
        Start-Process $oneDriveSetup "/uninstall" -Wait -NoNewWindow -ErrorAction SilentlyContinue
        Write-Host "OneDrive uninstalled."
    } catch { Write-Host "OneDrive uninstall skipped." }
} else {
    Write-Host "OneDrive installer not found; skipping."
}

# -------------------------------
# 3) System policies (HKLM) to block ads/consumer experiences
# -------------------------------
Write-Host "Applying system policies (HKLM) to block consumer experiences and ads..."

# CloudContent: stop consumer experiences & third-party suggestions
$polCloud = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
New-Item -Path $polCloud -Force | Out-Null
New-ItemProperty -Path $polCloud -Name "DisableWindowsConsumerFeatures" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $polCloud -Name "DisableThirdPartySuggestions"  -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $polCloud -Name "DisableSoftLanding"            -Value 1 -PropertyType DWord -Force | Out-Null

# System: turn off tailored experiences (ads based on diagnostic data)
$polSystem = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
New-Item -Path $polSystem -Force | Out-Null
New-ItemProperty -Path $polSystem -Name "DisableTailoredExperiencesWithDiagnosticData" -Value 1 -PropertyType DWord -Force | Out-Null

# Windows Search: disable web integration/suggestions in Start
$polSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
New-Item -Path $polSearch -Force | Out-Null
New-ItemProperty -Path $polSearch -Name "DisableSearchBoxSuggestions" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $polSearch -Name "DisableWebSearch"            -Value 1 -PropertyType DWord -Force | Out-Null

# Widgets/News & Interests (feeds engine)
try {
    $polDsh = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
    New-Item -Path $polDsh -Force | Out-Null
    New-ItemProperty -Path $polDsh -Name "AllowNewsAndInterests" -Value 0 -PropertyType DWord -Force | Out-Null
} catch {}

# Optional: lock screen Spotlight (policy)
try {
    $lockPol = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    New-Item -Path $lockPol -Force | Out-Null
    # These don’t “disable Spotlight” directly, but reduce lock-screen surface
    New-ItemProperty -Path $lockPol -Name "NoLockScreenCamera"     -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $lockPol -Name "NoLockScreenSlideshow"  -Value 1 -PropertyType DWord -Force | Out-Null
} catch {}

# -------------------------------
# 4) Disable CEIP/telemetry-related scheduled tasks
# -------------------------------
Write-Host "Disabling CEIP/telemetry-related scheduled tasks..."
$tasks = @(
  "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
  "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
  "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
  "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
  "\Microsoft\Windows\Feedback\Siuf\DmClient",
  "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
  "\Microsoft\Windows\Maps\MapsUpdateTask",
  "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
)
foreach ($t in $tasks) {
    try {
        schtasks /Change /TN $t /Disable | Out-Null
        Write-Host "Disabled task: $t"
    } catch {
        Write-Host "  Could not disable (may not exist): $t"
    }
}

Write-Host "`nCompleted (ADMIN). Reboot to finalize. For per-user UX tweaks (Start/Explorer recents, Widgets button, Spotlight, ad ID), run the separate userspace script after logging into each account."
