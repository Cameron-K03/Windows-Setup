# Script: Install-GamerPrograms.ps1
# Description: Installs a set of programs commonly used by gamers.

# List of software to install with winget IDs and descriptions
$softwareList = @(
    "Valve.Steam",                              # Steam - Gaming platform and store
    "EpicGames.EpicGamesLauncher",              # Epic Games Launcher - Epic's gaming platform
    "ElectronicArts.Origin",                    # Origin - EA's gaming platform
    "Blizzard.BattleNet",                       # Battle.net - Blizzard's gaming platform
    "GOG.Galaxy",                               # GOG Galaxy - GOG's gaming platform
    "Razer.Synapse",                            # Razer Synapse - Razer peripherals configuration
    "Nvidia.GeForceExperience",                 # GeForce Experience - NVIDIA's game optimization and recording
    "AdvancedMicroDevicesInc.RadeonSoftware",   # AMD Radeon Software - AMD's GPU management software
    "MSIAfterburner.MSIAfterburner",            # MSI Afterburner - GPU overclocking tool
    "OBSProject.OBSStudio",                     # OBS Studio - Open-source streaming software
    "Discord.Discord",                          # Discord - Chat for communities and gamers
    "TeamSpeakSystems.TeamSpeak",               # TeamSpeak - Voice communication software
    "NexusMods.Vortex",                         # Vortex - Mod manager for games
    "Twitch.Twitch",                            # Twitch - Live streaming platform
    "Beepa.Fraps",                              # Fraps - Screen capture and benchmarking
    "Guru3D.RivatunerStatisticsServer",         # Rivatuner Statistics Server - Hardware monitoring tool
    "Microsoft.XboxGameBar",                    # Game Bar - Windows' built-in game bar
    "JTK.JoyToKey",                             # JoyToKey - Map joystick inputs to keyboard
    "Ryochan7.DS4Windows"                       # DS4Windows - Use DualShock 4 on Windows
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

# Finish WinGet stuff
Wingetget
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
