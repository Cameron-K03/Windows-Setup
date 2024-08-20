$ProgressPreference = 'SilentlyContinue'  # Suppress the progress bar for faster downloads
$installerDir = "$env:TEMP\WingetInstallers"
New-Item -Path $installerDir -ItemType Directory -Force | Out-Null

$installerFiles = @{
    "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" = "https://aka.ms/getwinget";
    "Microsoft.VCLibs.x64.14.00.Desktop.appx" = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx";
    "Microsoft.UI.Xaml.2.8.x64.appx" = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx";
    "latestWingetMsixBundle" = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
}

foreach ($file in $installerFiles.GetEnumerator()) {
    $filePath = Join-Path -Path $installerDir -ChildPath $file.Key

    try {
        Write-Output "Downloading $($file.Key)..."
        Invoke-WebRequest -Uri $file.Value -OutFile $filePath -ErrorAction Stop
    } catch {
        Write-Output "Failed to download $($file.Key): $($_.Exception.Message)"
        return
    }
}

# Install packages
foreach ($file in $installerFiles.Keys) {
    $filePath = Join-Path -Path $installerDir -ChildPath $file
    if (Test-Path $filePath) {
        try {
            Write-Output "Installing $file..."
            Add-AppxPackage -Path $filePath -ErrorAction Stop
        } catch {
            Write-Output "Failed to install {$file}: $($_.Exception.Message)"
            return
        }
    } else {
        Write-Output "$file not found at $filePath"
    }
}

# Output the installed Winget version
Write-Output "Installed Winget version:"
winget --version
