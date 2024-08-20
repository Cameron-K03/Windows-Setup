# Get list of installed applications
$installedApps = Get-WmiObject -Query "SELECT * FROM Win32_Product"

foreach ($app in $installedApps) {
    try {
        # Attempt to uninstall the application
        Write-Output "Attempting to uninstall $($app.Name)..."
        $app.Uninstall() | Out-Null
        Write-Output "$($app.Name) has been uninstalled."
    } catch {
        # Handle access denied errors or other issues
        Write-Output "Failed to uninstall $($app.Name). Access denied or other issue."
    }
}

Write-Output "Uninstallation process completed."
