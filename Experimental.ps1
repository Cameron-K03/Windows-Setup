function Try-UninstallApp {
    param (
        [string]$appName
    )

    $uninstalled = $false

    function Is-AppStillInstalled {
        param ($appName)
        $remainingApp = Get-Package -Name $appName -ErrorAction SilentlyContinue
        if ($remainingApp) {
            return $true
        } else {
            return $false
        }
    }

    # Try using Get-Package
    try {
        Write-Output "Attempting to uninstall $appName using Get-Package..."
        Uninstall-Package -Name $appName -Force -ErrorAction Stop | Out-Null
        Start-Sleep -Seconds 5  # Give it a moment to update the list
        if (-not (Is-AppStillInstalled $appName)) {
            Write-Output "$appName has been uninstalled using Get-Package."
            $uninstalled = $true
        } else {
            Write-Output "$appName is still listed after attempting to uninstall with Get-Package."
        }
    } catch {
        Write-Output "Failed to uninstall $appName using Get-Package."
    }

    # Try using WMIC if Get-Package fails
    if (-not $uninstalled) {
        try {
            Write-Output "Attempting to uninstall $appName using WMIC..."
            $wmicUninstall = wmic product where "name='$appName'" call uninstall /nointeractive
            Start-Sleep -Seconds 5  # Give it a moment to update the list
            if (-not (Is-AppStillInstalled $appName)) {
                Write-Output "$appName has been uninstalled using WMIC."
                $uninstalled = $true
            } else {
                Write-Output "$appName is still listed after attempting to uninstall with WMIC."
            }
        } catch {
            Write-Output "Error occurred while uninstalling $appName with WMIC."
        }
    }

    # Try using the native uninstaller if WMIC fails
    if (-not $uninstalled) {
        $possibleUninstallPaths = @(
            "C:\Program Files\{0}\uninstall.exe",
            "C:\Program Files (x86)\{0}\uninstall.exe",
            "C:\Program Files\{0}\unins000.exe",
            "C:\Program Files (x86)\{0}\unins000.exe"
        )

        foreach ($pathTemplate in $possibleUninstallPaths) {
            $uninstallPath = -f $pathTemplate -f $appName
            if (Test-Path $uninstallPath) {
                try {
                    Write-Output "Attempting to uninstall $appName using its native uninstaller..."
                    Start-Process -FilePath $uninstallPath -ArgumentList '/SILENT', '/VERYSILENT', '/NORESTART' -Wait
                    Start-Sleep -Seconds 5  # Give it a moment to update the list
                    if (-not (Is-AppStillInstalled $appName)) {
                        Write-Output "$appName has been uninstalled using its native uninstaller."
                        $uninstalled = $true
                        break
                    } else {
                        Write-Output "$appName is still listed after attempting to uninstall with its native uninstaller."
                    }
                } catch {
                    Write-Output "Failed to uninstall $appName using its native uninstaller."
                }
            }
        }
    }

    # Try using the registry uninstall string if the above methods fail
    if (-not $uninstalled) {
        $64BitProgramsList = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty
        $32BitProgramsList = Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty
        $SearchList = $32BitProgramsList + $64BitProgramsList

        $Programs = $SearchList | Where-Object { $_.DisplayName -match $appName }
        if ($Programs) {
            foreach ($Program in $Programs) {
                if (Test-Path $Program.PSPath) {
                    try {
                        Write-Output "Running uninstall command for $($Program.DisplayName) from registry..."
                        Start-Process cmd.exe -ArgumentList '/c', $Program.UninstallString -Wait -PassThru
                        Start-Sleep -Seconds 5  # Give it a moment to update the list
                        if (-not (Is-AppStillInstalled $appName)) {
                            Write-Output "$($Program.DisplayName) has been uninstalled using its registry uninstall string."
                            $uninstalled = $true
                            break
                        } else {
                            Write-Output "$appName is still listed after attempting to uninstall with its registry uninstall string."
                        }
                    } catch {
                        Write-Output "Failed to uninstall $($Program.DisplayName) using its registry uninstall string."
                    }
                }
            }
        } else {
            Write-Output "No matching program found in the registry!"
        }
    }

    if (-not $uninstalled) {
        Write-Output "$appName could not be uninstalled using any method."
    }
}

# Loop through each app and attempt to uninstall using all methods
foreach ($appName in $combinedAppNames) {
    Try-UninstallApp -appName $appName
}

Write-Output "Uninstallation process completed."
