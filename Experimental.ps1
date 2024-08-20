function Try-UninstallApp {
    param (
        [string]$appName
    )

    $uninstalled = $false

    # Try using Get-Package
    try {
        Write-Output "Attempting to uninstall $appName using Get-Package..."
        $packageApp = Get-Package -Name $appName -ErrorAction Stop
        if ($packageApp) {
            Uninstall-Package -Name $appName -Force -ErrorAction Stop | Out-Null
            Write-Output "$appName has been uninstalled using Get-Package."
            $uninstalled = $true
        }
    } catch {
        Write-Output "Failed to uninstall $appName using Get-Package."
    }

    # Try using WMIC if Get-Package fails
    if (-not $uninstalled) {
        try {
            Write-Output "Attempting to uninstall $appName using WMIC..."
            $wmicUninstall = wmic product where "name='$appName'" call uninstall /nointeractive
            if ($wmicUninstall.ReturnValue -eq 0) {
                Write-Output "$appName has been uninstalled using WMIC."
                $uninstalled = $true
            } else {
                Write-Output "Failed to uninstall $appName using WMIC."
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
                    Write-Output "$appName has been uninstalled using its native uninstaller."
                    $uninstalled = $true
                    break
                } catch {
                    Write-Output "Failed to uninstall $appName using its native uninstaller."
                }
            }
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
