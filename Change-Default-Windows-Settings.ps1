# Function to safely set registry properties
function Set-SafeItemProperty {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Value
    )
    if (Test-Path $Path) {
        Set-ItemProperty -Path $Path -Name $Name -Value $Value
    } else {
        Write-Output "Path $Path does not exist."
    }
}

# Set Background to Picture
Set-SafeItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value "C:\Path\To\Your\Picture.jpg"
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Disable Fun Facts and Lock Screen Status
Set-SafeItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Value 0
Set-SafeItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Value 0

# Taskbar: Disable Copilot, Task View, Widgets, and Hide Search
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowWidgetsButton" -Value 0
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0

# Taskbar Behaviors (replicate from image)
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSi" -Value 1
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbar" -Value 0

# Device Usage - Turn Off Everything
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Value 0

# Share Across Devices - Turn Off
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "CdpSessionUserAuthzPolicy" -Value 0

# Manage Startup Apps
$startupApps = Get-CimInstance Win32_StartupCommand
$startupApps | ForEach-Object {
    if ($_.Command -notlike "*Hardware App Name*") {
        Set-SafeItemProperty -Path $_.Command -Name "Disabled" -Value 1
    }
}

# Windows Backup - Turn Everything Off
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\WindowsBackup" -Name "DisableBackup" -Value 1

# Typing Insights - Turn Off
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextInput" -Value 1

# Accessibility: Show Scrollbars, Turn Off Transparency, Animation
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "Scrollbars" -Value 1
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "Transparency" -Value 0
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "Animation" -Value 0

# Captions - Turn Off
Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Accessibility" -Name "ClosedCaptioning" -Value 0

# Privacy & Security Settings
$privacySettings = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo",
    "HKCU:\Software\Microsoft\InputPersonalization",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Location",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Speech",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feedback",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudContent"
)
$privacySettings | ForEach-Object {
    Set-SafeItemProperty -Path $_ -Name "Value" -Value 0
}

# Delivery Optimization - Turn Off
Set-SafeItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Value 0

# Other App Permissions
$appPermissions = @(
    "Location", "Camera", "Microphone", "VoiceActivation", "Notifications", 
    "AccountInfo", "Contacts", "Calendar", "PhoneCalls", "CallHistory", 
    "Email", "Tasks", "Messaging", "Radios", "OtherDevices", 
    "AppDiagnostics", "AutomaticFileDownloads", "MusicLibrary", "ScreenshotsAndApps"
)
foreach ($permission in $appPermissions) {
    Set-SafeItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppPermissions\$permission" -Name "Value" -Value 0
}
