# Script: Install-DefaultPrograms.ps1
# Description: Installs a standard set of programs for a typical Windows user.

# List of software to install with winget IDs
$softwareList = @(
    @{ Name = "Rufus"; WingetID = "Rufus.Rufus" },                            # Rufus - Create bootable USB drives
    @{ Name = "Etcher"; WingetID = "Balena.Etcher" },                         # Etcher - Flash OS images to SD cards
    @{ Name = "Ventoy"; WingetID = "ventoy.Ventoy" },                         # Ventoy - Boot multiple ISO files from USB
    @{ Name = "TreeSize Free"; WingetID = "JAMSoftware.TreeSize.Free" },      # TreeSize Free - Disk space analyzer
    @{ Name = "SpaceSniffer"; WingetID = "UderzoSoftware.SpaceSniffer" },     # SpaceSniffer - Visualize disk space usage
    @{ Name = "Revo Uninstaller"; WingetID = "RevoUninstaller.RevoUninstaller" }, # Revo Uninstaller - Remove unwanted programs
    @{ Name = "7-zip"; WingetID = "mcmilk.7zip-zstd" },                       # 7-zip - File archiver with high compression
    @{ Name = "ImageGlass"; WingetID = "DuongDieuPhap.ImageGlass" },          # ImageGlass - Image viewer for Windows
    @{ Name = "GlassWire Lite"; WingetID = "GlassWire.GlassWire.Lite" },      # GlassWire - Network security monitoring
    @{ Name = "MSI Kombustor"; WingetID = "MSI.Kombustor.4" },                # MSI Kombustor - GPU stress test tool
    @{ Name = "VLC Media Player"; WingetID = "VideoLAN.VLC" },                # VLC Media Player - open-source multimedia player
    @{ Name = "Paint.net"; WingetID = "dotPDNLLC.paintdotnet" },              # Paint.net - image editor
    @{ Name = "Microsoft 365 Apps"; WingetID = "Microsoft.Office" },          # Microsoft 365 Apps - All the Microsoft office apps
    @{ Name = "Firefox"; WingetID = "Mozilla.Firefox" },                      # Firefox - open-source web browser
    @{ Name = "Git"; WingetID = "Git.Git" },                                  # Git - Version control system
    @{ Name = "NordVPN"; WingetID = "NordVPN.NordVPN" },                      # NordVPN - VPN service for privacy
    @{ Name = "HWMonitor"; WingetID = "CPUID.HWMonitor" },                    # HWMonitor - Hardware monitoring tool
    @{ Name = "CPU-Z"; WingetID = "CPUID.CPU-Z" },                            # CPU-Z - CPU information tool
    @{ Name = "GPU-Z"; WingetID = "TechPowerUp.GPU-Z" },                      # GPU-Z - GPU information tool
    @{ Name = "WhatsApp"; WingetID = "WhatsApp.WhatsApp" },                   # WhatsApp - Messaging and calling application
    @{ Name = "Discord"; WingetID = "Discord.Discord" },                      # Discord - Chat for communities and gamers
    @{ Name = "Microsoft Visual C++ Redistributable (x86)"; WingetID = "Microsoft.VCRedist.2015+.x86" },    # Microsoft Visual C++ 2015-2022 Redistributable (x86)
    @{ Name = "Microsoft Visual C++ Redistributable (x64)"; WingetID = "Microsoft.VCRedist.2015+.x64" }     # Microsoft Visual C++ 2015-2022 Redistributable (x64)
)

# Function to check and install Winget if not installed
function Wingetget {
    $ProgressPreference = 'SilentlyContinue'  # Suppress the progress bar for faster downloads
    $installerDir = "$env:TEMP\WingetInstallers"
    New-Item -Path $installerDir -ItemType Directory -Force | Out-Null

    $installerFiles = @{
        "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" = "https://aka.ms/getwinget";
        "Microsoft.VCLibs.x64.14.00.Desktop.appx" = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx";
        "Microsoft.UI.Xaml.2.8.x64.appx" = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
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

    # Clean up
    Remove-Item -Path $installerDir -Recurse -Force
}

# Function to install software using Winget
function Install-Software {
    foreach ($software in $softwareList) {
        Write-Output "Installing $($software.Name)..."
        winget install --id $($software.WingetID) --silent --accept-source-agreements --accept-package-agreements
    }
}

# Check if Winget is installed
$wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue

if ($null -eq $wingetInstalled) {
    Write-Output "Winget is not installed. Installing Winget and its dependencies..."
    Wingetget
}

# Output the installed Winget version or confirmation of installation
Write-Output "Winget version:"
winget --version

# Proceed to install software
Install-Software

Write-Output "Installation process completed."
