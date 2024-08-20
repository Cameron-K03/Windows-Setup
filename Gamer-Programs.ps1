# Script: Install-GamerPrograms.ps1
# Description: Installs a set of programs commonly used by gamers.

# List of software to install with winget IDs and descriptions
$softwareList = @(
    @{ Name = "Steam"; WingetID = "Valve.Steam" },                              # Steam - Gaming platform and store
    @{ Name = "Epic Games Launcher"; WingetID = "EpicGames.EpicGamesLauncher" }, # Epic Games Launcher - Epic's gaming platform
    @{ Name = "Origin"; WingetID = "ElectronicArts.Origin" },                    # Origin - EA's gaming platform
    @{ Name = "Battle.net"; WingetID = "Blizzard.BattleNet" },                   # Battle.net - Blizzard's gaming platform
    @{ Name = "GOG Galaxy"; WingetID = "GOG.Galaxy" },                           # GOG Galaxy - GOG's gaming platform
    @{ Name = "GeForce Experience"; WingetID = "Nvidia.GeForceExperience" },     # GeForce Experience - NVIDIA's game optimization and recording
    @{ Name = "OBS Studio"; WingetID = "OBSProject.OBSStudio" },                 # OBS Studio - Open-source streaming software
    @{ Name = "Discord"; WingetID = "Discord.Discord" },                         # Discord - Chat for communities and gamers
    @{ Name = "Vortex"; WingetID = "NexusMods.Vortex" },                         # Vortex - Mod manager for games
    @{ Name = "DS4Windows"; WingetID = "Ryochan7.DS4Windows" }                   # DS4Windows - Use DualShock 4 on Windows
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
Write-Output "Enjoy your games."
