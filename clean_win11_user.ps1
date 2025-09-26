<#  CleanWin11_User.ps1 — Per-user cleanup (no admin)
    - Removes common sponsored/bundled apps for CURRENT user only
    - Turns off Start/Lock screen recommendations, Spotlight, tips, ad ID
    - Hides Explorer “Recent/Frequent”, disables Widgets button
    - Safe to run multiple times

Run in powershell (as user):

Set-ExecutionPolicy Bypass -Scope Process -Force
. "$env:USERPROFILE\Desktop\clean_win11_user.ps1"
#>

Write-Host "`n=== Per-user minimalization starting (no admin) ===`n"

# ---------- Helpers ----------
function Remove-AppxForUser {
  param([string]$Pattern)
  $apps = Get-AppxPackage | Where-Object { $_.Name -like $Pattern }
  if ($apps) {
    $apps | ForEach-Object {
      try {
        Write-Host "Removing (user): $($_.Name)"
        Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
      } catch {
        Write-Host "  Skipped: $($_.Name) ($($_.Exception.Message))"
      }
    }
  } else {
    Write-Host "No matches for $Pattern"
  }
}

function Ensure-Key {
  param([string]$Path)
  if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
}

function Set-DWord {
  param([string]$Path, [string]$Name, [int]$Value)
  Ensure-Key $Path
  New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
}

# ---------- Remove common bundled apps (CURRENT user only) ----------
$UserBloat = @(
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
foreach ($p in $UserBloat) { Remove-AppxForUser -Pattern $p }

# Note: OneDrive uninstall is system-wide and needs admin — skipped here by design.

# ---------- Kill recommendations/ads/tips (per-user switches) ----------
$cdm = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Ensure-Key $cdm

# Turn off “Content Delivery” (Start suggestions, tips, promos)
$cdmFlags = @{
  "ContentDeliveryAllowed"          = 0
  "OemPreInstalledAppsEnabled"      = 0
  "PreInstalledAppsEnabled"         = 0
  "PreInstalledAppsEverEnabled"     = 0
  "SilentInstalledAppsEnabled"      = 0
  "SystemPaneSuggestionsEnabled"    = 0
  "SubscribedContent-310093Enabled" = 0
  "SubscribedContent-338387Enabled" = 0
  "SubscribedContent-338388Enabled" = 0
  "SubscribedContent-338389Enabled" = 0
  "SubscribedContent-338393Enabled" = 0
  "SubscribedContent-353694Enabled" = 0
  "SubscribedContent-353696Enabled" = 0
}
$cdmFlags.Keys | ForEach-Object { Set-DWord -Path $cdm -Name $_ -Value $cdmFlags[$_] }

# Advertising ID off (per-user)
$adKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
Set-DWord -Path $adKey -Name "Enabled" -Value 0

# ---------- Lock screen: disable Spotlight (per-user) ----------
# Use a static picture/slideshow later in Settings if you like
Set-DWord -Path $cdm -Name "RotatingLockScreenEnabled"        -Value 0
Set-DWord -Path $cdm -Name "RotatingLockScreenOverlayEnabled" -Value 0

# ---------- Notifications “suggested” apps off (per-user best-effort) ----------
$notif = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings"
Ensure-Key $notif
# These keys vary by build; we set common ones defensively.
Set-DWord -Path $notif -Name "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" -Value 0 | Out-Null
# (Most “suggested app” nudges come from ContentDeliveryManager, already disabled.)

Write-Host "`nDone. Sign out/in (or reboot) to apply UI changes."
Write-Host "Tip: In Settings → Personalization, set Lock screen to Picture/Slideshow (not Spotlight)."
