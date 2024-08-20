# Script: Install-GamerPrograms.ps1
# Description: Installs a set of programs commonly used by gamers.

# List of software to install with winget IDs and descriptions
$softwareList = @(
    @{ Name = "Steam"; WingetID = "Valve.Steam" },                              # Steam - Gaming platform and store
    @{ Name = "Epic Games Launcher"; WingetID = "EpicGames.EpicGamesLauncher" }, # Epic Games Launcher - Epic's gaming platform
    @{ Name = "Origin"; WingetID = "ElectronicArts.Origin" },                    # Origin - EA's gaming platform
    @{ Name = "Battle.net"; WingetID = "Blizzard.BattleNet" },                   # Battle.net - Blizzard's gaming platform
    @{ Name = "GOG Galaxy"; WingetID = "GOG.Galaxy" },                           # GOG Galaxy - GOG's gaming platform
    @{ Name = "Razer Synapse"; WingetID = "Razer.Synapse" },                     # Razer Synapse - Razer peripherals configuration
    @{ Name = "GeForce Experience"; WingetID = "Nvidia.GeForceExperience" },     # GeForce Experience - NVIDIA's game optimization and recording
    @{ Name = "AMD Radeon Software"; WingetID = "AdvancedMicroDevicesInc.RadeonSoftware" }, # AMD Radeon Software - AMD's GPU management software
    @{ Name = "MSI Afterburner"; WingetID = "MSIAfterburner.MSIAfterburner" },   # MSI Afterburner - GPU overclocking tool
    @{ Name = "OBS Studio"; WingetID = "OBSProject.OBSStudio" },                 # OBS Studio - Open-source streaming software
    @{ Name = "Discord"; WingetID = "Discord.Discord" },                         # Discord - Chat for communities and gamers
    @{ Name = "TeamSpeak"; WingetID = "TeamSpeakSystems.TeamSpeak" },            # TeamSpeak - Voice communication software
    @{ Name = "Vortex"; WingetID = "NexusMods.Vortex" },                         # Vortex - Mod manager for games
    @{ Name = "Twitch"; WingetID = "Twitch.Twitch" },                            # Twitch - Live streaming platform
    @{ Name = "Fraps"; WingetID = "Beepa.Fraps" },                               # Fraps - Screen capture and benchmarking
    @{ Name = "Rivatuner Statistics Server"; WingetID = "Guru3D.RivatunerStatisticsServer" }, # Rivatuner Statistics Server - Hardware monitoring tool
    @{ Name = "Xbox Game Bar"; WingetID = "Microsoft.XboxGameBar" },             # Game Bar - Windows' built-in game bar
    @{ Name = "JoyToKey"; WingetID = "JTK.JoyToKey" },                           # JoyToKey - Map joystick inputs to keyboard
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

# Download and install AMD Adrenalin the hard way because they hate me (and dynamic links)
$htmlContent = (Invoke-WebRequest -Uri "https://www.amd.com/en/support/download/drivers.html" -Headers $headers).Content
$amdDownloadLink = [regex]::Match(
    $htmlContent,
    'https:\/\/drivers\.amd\.com\/drivers\/installer\/[0-9\.]+\/whql\/amd-software-adrenalin-edition-[0-9\.]+-minimalsetup-[0-9]+_web\.exe'
).Value

if ($amdDownloadLink) {
    DownloadAndInstall -DownloadUrl $amdDownloadLink -DownloadPath "$env:TEMP\AMD_Adrenalin.exe"
}

# Download and install Battle.net (manual download)
DownloadAndInstall -DownloadUrl "https://downloader.battle.net/download/getInstallerForGame?os=win&gameProgram=BATTLENET_APP&version=Live" -DownloadPath "$env:TEMP\BattleNetInstaller.exe" -InstallerArgs "/S"

Write-Output "Enjoy your games."
