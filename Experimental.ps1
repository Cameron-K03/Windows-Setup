function Get-InstalledAppsWin32 {
    try {
        # Check if the Win32_Product class is valid
        $classCheck = Get-WmiObject -List | Where-Object { $_.Name -eq 'Win32_Product' }
        if ($classCheck) {
            $apps = Get-WmiObject -Query "SELECT * FROM Win32_Product"
            return $apps
        } else {
            Write-Output "Win32_Product class is invalid or not available."
            return $null
        }
    } catch {
        Write-Output "Failed to retrieve apps using Win32_Product."
        return $null
    }
}

function Get-InstalledAppsPackage {
    try {
        $apps = Get-Package
        return $apps
    } catch {
        Write-Output "Failed to retrieve apps using Get-Package."
        return $null
    }
}

# Retrieve installed applications using Win32_Product and Get-Package
$win32Apps = Get-InstalledAppsWin32
$packageApps = Get-InstalledAppsPackage

# If both methods succeeded, cross-reference and merge the lists
if ($win32Apps -and $packageApps) {
    $win32AppNames = $win32Apps.Name
    $packageAppNames = $packageApps.Name

    # Merge lists and remove duplicates
    $combinedAppNames = $win32AppNames + $packageAppNames | Sort-Object -Unique
} elseif ($win32Apps) {
    $combinedAppNames = $win32Apps.Name
} elseif ($packageApps) {
    $combinedAppNames = $packageApps.Name
} else {
    Write-Output "No applications found using either method."
    exit
}

foreach ($appName in $combinedAppNames) {
    try {
        # Attempt to uninstall using Win32_Product
        $app = $win32Apps | Where-Object { $_.Name -eq $appName }
        if ($app) {
            Write-Output "Attempting to uninstall $($app.Name) using Win32_Product..."
            $app.Uninstall() | Out-Null
            Write-Output "$($app.Name) has been uninstalled using Win32_Product."
        } else {
            # Attempt to uninstall using Get-Package if not found in Win32_Product
            $appPackage = $packageApps | Where-Object { $_.Name -eq $appName }
            if ($appPackage) {
                Write-Output "Attempting to uninstall $($appPackage.Name) using Get-Package..."
                Uninstall-Package -Name $appPackage.Name -Force -ErrorAction Stop | Out-Null
                Write-Output "$($appPackage.Name) has been uninstalled using Get-Package."
            }
        }
    } catch {
        # Handle access denied errors or other issues
        Write-Output "Failed to uninstall $appName. Access denied or other issue."
    }
}

Write-Output "Uninstallation process completed for some things. Maybe try Revo Uninstaller to get the rest..."
