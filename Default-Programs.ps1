# Script: Install-DefaultPrograms.ps1
# Description: Installs a standard set of programs for a typical Windows user.

# List of software to install with winget IDs
$softwareList = @(
    "Rufus.Rufus",                            # Rufus - Create bootable USB drives
    "Balena.Etcher",                          # Etcher - Flash OS images to SD cards
    "ventoy.Ventoy",                          # Ventoy - Boot multiple ISO files from USB
    "JAMSoftware.TreeSize.Free",              # TreeSize Free - Disk space analyzer
    "UderzoSoftware.SpaceSniffer",            # SpaceSniffer - Visualize disk space usage
    "RevoUninstaller.RevoUninstaller",        # Revo Uninstaller - Remove unwanted programs
    "mcmilk.7zip-zstd",                       # 7-zip - File archiver with high compression
    "DuongDieuPhap.ImageGlass",               # ImageGlass - Image viewer for Windows
    "GlassWire.GlassWire.Lite",               # GlassWire - Network security monitoring
    "MSI.Kombustor.4",                        # MSI Kombustor - GPU stress test tool
    "VideoLAN.VLC",                           # VLC Media Player - open-source multimedia player
    "dotPDNLLC.paintdotnet",                  # Paint.net - image editor
    "Microsoft.Office",                       # Microsoft 365 Apps - All the microsoft office apps
    "Mozilla.Firefox",                        # Firefox - open-source web browser
    "Git.Git",                                # Git - Version control system
    "NordVPN.NordVPN",                        # NordVPN - VPN service for privacy
    "CPUID.HWMonitor",                        # HWMonitor - Hardware monitoring tool
    "CPUID.CPU-Z",                            # CPU-Z - CPU information tool
    "TechPowerUp.GPU-Z",                      # GPU-Z - GPU information tool
    "WhatsApp.WhatsApp",                      # WhatsApp - Messaging and calling application
	"Discord.Discord"						  # Discord - "Chat for communities and gamers
    "Microsoft.VCRedist.2015+.x86"   		  # Microsoft Visual C++ 2015-2022 Redistributable (x86)
	"Microsoft.VCRedist.2015+.x64"   	      # Microsoft Visual C++ 2015-2022 Redistributable (x64)

)

# Get winget
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

# Install software
function Install-Software {
    foreach ($software in $softwareList) {
        Write-Output "Installing $($software.Name)..."
        winget install --id $($software.WingetID) --silent --accept-source-agreements --accept-package-agreements
    }
}

# Run all functions
Wingetget
Install-Software

Write-Output "Installation process completed."
