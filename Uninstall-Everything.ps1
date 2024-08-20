# Function to retrieve installed programs from the registry
function Get-InstalledPrograms {
    param (
        [string]${registryKey}
    )

    try {
        $programs = Get-ItemProperty ${registryKey} |
                    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, UninstallString |
                    Where-Object { $_.DisplayName -ne $null }
        return $programs
    } catch {
        Write-Output "Failed to retrieve programs from ${registryKey}: $($_.Exception.Message)"
        return $null
    }
}

# Retrieve programs from Local Machine and Current User registry keys
$programsHKLM = Get-InstalledPrograms -registryKey "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
$programsHKLM += Get-InstalledPrograms -registryKey "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
$programsHKCU = Get-InstalledPrograms -registryKey "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"

# Combine all found programs into one list
$allPrograms = $programsHKLM + $programsHKCU | Where-Object { $_.DisplayName }

# Function to execute a command and handle errors gracefully
function Execute-Command {
    param (
        [string]$command,
        [string]$programName
    )
    
    try {
        $process = Start-Process "cmd.exe" -ArgumentList "/c $command" -Wait -NoNewWindow -PassThru
        $process.WaitForExit()
        return $process.ExitCode
    } catch {
        Write-Output "Error executing the command for {$programName}: $($_.Exception.Message)"
        return 1
    }
}

# Function to open the Control Panel's Add/Remove Programs interface for a specific program
function Fallback-ControlPanelUninstall {
    param (
        [string]$programName
    )

    Write-Output "Attempting to uninstall $programName using the Control Panel..."

    # Open Control Panel to the specific program's uninstall page
    Start-Process "control.exe" -ArgumentList "appwiz.cpl,,2" -Wait

    Write-Output "Please manually uninstall $programName via the Control Panel."
}

# Uninstall each program using the UninstallString with enhanced error handling
foreach ($program in $allPrograms) {
    $programName = $program.DisplayName
    $uninstallCommand = $program.UninstallString

    if ($uninstallCommand) {
        Write-Output "Attempting to silently uninstall $programName..."

        # Handle MSI-based uninstall commands
        if ($uninstallCommand -match "MsiExec.exe") {
            if ($uninstallCommand -notmatch "/X" -and $uninstallCommand -match "\{.*\}") {
                # If /X is missing but a product code is present, add /X and quiet options
                $uninstallCommand = "MsiExec.exe /X" + $uninstallCommand.Trim("MsiExec.exe") + " /quiet /norestart"
            } elseif ($uninstallCommand -match "/X") {
                $uninstallCommand += " /quiet /norestart"
            } else {
                Write-Output "Uninstall command for $programName does not include /X or a product code. Skipping..."
                continue
            }

            # Attempt silent uninstallation
            $silentExitCode = Execute-Command -command $uninstallCommand -programName $programName

            # If silent uninstall fails, retry without silent flags
            if ($silentExitCode -ne 0) {
                Write-Output "Silent uninstall failed for $programName. Retrying interactively..."
                $uninstallCommand = $uninstallCommand.Replace(" /quiet /norestart", "")
                $interactiveExitCode = Execute-Command -command $uninstallCommand -programName $programName

                if ($interactiveExitCode -ne 0) {
                    Write-Output "Interactive uninstall also failed. Falling back to Control Panel for $programName."
                    Fallback-ControlPanelUninstall -programName $programName
                }
            }
        } else {
            # For other types of uninstallers, try adding common silent flags
            if ($uninstallCommand -match ".exe") {
                $silentCommand = $uninstallCommand + " /S /quiet /norestart"
                $silentExitCode = Execute-Command -command $silentCommand -programName $programName

                # If silent uninstall fails, retry without silent flags
                if ($silentExitCode -ne 0) {
                    Write-Output "Silent uninstall failed for $programName. Retrying interactively..."
                    $interactiveExitCode = Execute-Command -command $uninstallCommand -programName $programName

                    if ($interactiveExitCode -ne 0) {
                        Write-Output "Interactive uninstall also failed. Falling back to Control Panel for $programName."
                        Fallback-ControlPanelUninstall -programName $programName
                    }
                }
            }
        }

        Write-Output "$programName has been uninstalled."
    } else {
        Write-Output "No uninstall command found for $programName. Skipping..."
    }

    Write-Output "-------------------------------------------"
}

Write-Output "Uninstallation process completed."
