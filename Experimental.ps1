# Set Background to Picture
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value "C:\Path\To\Your\Picture.jpg"
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Disable Fun Facts and Lock Screen Status
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Value 0

# Taskbar: Disable Copilot, Task View, Widgets, and Hide Search
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowWidgetsButton" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0

# Taskbar Behaviors (replicate from image)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSi" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbar" -Value 0

# Device Usage - Turn Off Everything
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Value 0

# Share Across Devices - Turn Off
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "CdpSessionUserAuthzPolicy" -Value 0

# Manage Startup Apps
$startupApps = Get-CimInstance Win32_StartupCommand
$startupApps | ForEach-Object {
    if ($_ -notlike "*Hardware App Name*") {
        Set-ItemProperty -Path $_.Command -Name "Disabled" -Value 1
    }
}

# Windows Backup - Turn Everything Off
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\WindowsBackup" -Name "DisableBackup" -Value 1

# Typing Insights - Turn Off
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextInput" -Value 1

# Accessibility: Show Scrollbars, Turn Off Transparency, Animation
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "Scrollbars" -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "Transparency" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "Animation" -Value 0

# Captions - Turn Off
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Accessibility" -Name "ClosedCaptioning" -Value 0

# Privacy & Security Settings
$privacySettings = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo\Enabled",
    "HKCU:\Software\Microsoft\InputPersonalization\RestrictImplicitTextInput",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Location\EnableLocation",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Speech\EnableOnlineSpeech",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\AllowTelemetry",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feedback\DoNotShowFeedback",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudContent\DisableSearchHighlights"
)
$privacySettings | ForEach-Object {
    Set-ItemProperty -Path $_ -Name "Value" -Value 0
}

# Delivery Optimization - Turn Off
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Value 0

# Other App Permissions
$appPermissions = @(
    "Location", "Camera", "Microphone", "VoiceActivation", "Notifications", 
    "AccountInfo", "Contacts", "Calendar", "PhoneCalls", "CallHistory", 
    "Email", "Tasks", "Messaging", "Radios", "OtherDevices", 
    "AppDiagnostics", "AutomaticFileDownloads", "MusicLibrary", "ScreenshotsAndApps"
)
foreach ($permission in $appPermissions) {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppPermissions\$permission" -Name "Value" -Value 0
}
