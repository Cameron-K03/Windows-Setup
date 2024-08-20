# Script: SystemOverview.ps1
# Description: Collects and displays installed programs with sorting and formatting.

# Define the output file path on the desktop
$outputFilePath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "InstalledPrograms.html")

# Function to safely parse dates and sort "Unknown" last
function SafeParseDate {
    param ([string]$dateStr)

    if ([string]::IsNullOrWhiteSpace($dateStr) -or $dateStr -eq "Unknown") {
        return [datetime]::ParseExact("01011901", "ddMMyyyy", $null)
    } else {
        return [datetime]::ParseExact($dateStr, "yyyyMMdd", $null)
    }
}

# Function to retrieve installed programs from the registry
function Get-InstalledPrograms {
    param (
        [string]$registryKey
    )

    try {
        $programs = Get-ItemProperty $registryKey |
                    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
                    ForEach-Object {
                        # Format InstallDate as "## / Month / ####" or "Unknown"
                        if ($_.InstallDate) {
                            $date = $_.InstallDate.ToString()
                            $_.InstallDate = [datetime]::ParseExact($date, "yyyyMMdd", $null).ToString("dd / MMMM / yyyy")
                        } else {
                            $_.InstallDate = "Unknown"
                        }
                        $_
                    }
        return $programs
    } catch {
        Write-Output "Failed to retrieve programs from {$registryKey}: $($_.Exception.Message)"
        return $null
    }
}

# Get programs from Local Machine, Current User, and then combine lists
$programsHKLM = Get-InstalledPrograms -registryKey "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
$programsHKLM += Get-InstalledPrograms -registryKey "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
$programsHKCU = Get-InstalledPrograms -registryKey "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
$allPrograms = $programsHKLM + $programsHKCU | Where-Object { $_.DisplayName }

# Sort programs, placing those with "Unknown" dates last
$allPrograms = $allPrograms | Sort-Object { 
    if ($_.InstallDate -eq "Unknown") { 
        [datetime]::MaxValue 
    } else { 
        try {
            [datetime]::ParseExact($_.InstallDate, "dd / MMMM / yyyy", $null)
        } catch {
            SafeParseDate $_.InstallDate
        }
    } 
}

# HTML/CSS/JS for displaying the data
$htmlContent = @"
<html>
<head>
    <title>System Overview</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; }
        h1 { font-size: 24px; color: #333; }
        h2 { font-size: 20px; color: #555; margin-top: 40px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; background-color: #fff; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #4CAF50; color: white; font-weight: bold; cursor: pointer; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #f1f1f1; }
        th, td { padding: 12px; }
    </style>
    <script>
        function sortTable(n, type) {
            var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
            table = document.getElementById("programTable");
            switching = true;
            dir = "asc"; 
            while (switching) {
                switching = false;
                rows = table.rows;
                for (i = 1; i < (rows.length - 1); i++) {
                    shouldSwitch = false;
                    x = rows[i].getElementsByTagName("TD")[n];
                    y = rows[i + 1].getElementsByTagName("TD")[n];
                    if (type === "num") {
                        if (dir === "asc" && parseFloat(x.innerHTML) > parseFloat(y.innerHTML)) {
                            shouldSwitch = true;
                            break;
                        } else if (dir === "desc" && parseFloat(x.innerHTML) < parseFloat(y.innerHTML)) {
                            shouldSwitch = true;
                            break;
                        }
                    } else if (type === "date") {
                        if (dir === "asc" && new Date(x.innerHTML) > new Date(y.innerHTML)) {
                            shouldSwitch = true;
                            break;
                        } else if (dir === "desc" && new Date(x.innerHTML) < new Date(y.innerHTML)) {
                            shouldSwitch = true;
                            break;
                        }
                    } else {
                        if (dir === "asc" && x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                            shouldSwitch = true;
                            break;
                        } else if (dir === "desc" && x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                            shouldSwitch = true;
                            break;
                        }
                    }
                }
                if (shouldSwitch) {
                    rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                    switching = true;
                    switchcount++;      
                } else {
                    if (switchcount === 0 && dir === "asc") {
                        dir = "desc";
                        switching = true;
                    }
                }
            }
        }
    </script>
</head>
<body>
    <h1>System Overview</h1>

    <h2>Installed Programs</h2>
    <table id="programTable">
        <tr>
            <th onclick="sortTable(0, 'str')">Program Name</th>
            <th onclick="sortTable(1, 'num')">Version</th>
            <th onclick="sortTable(2, 'str')">Publisher</th>
            <th onclick="sortTable(3, 'date')">Install Date</th>
        </tr>
"@

foreach ($program in $allPrograms) {
    $htmlContent += "<tr>"
    $htmlContent += "<td>$($program.DisplayName)</td>"
    $htmlContent += "<td>$($program.DisplayVersion)</td>"
    $htmlContent += "<td>$($program.Publisher)</td>"
    $htmlContent += "<td>$($program.InstallDate)</td>"
    $htmlContent += "</tr>"
}

$htmlContent += @"
    </table>
</body>
</html>
"@

# Write HTML content to file
$htmlContent | Out-File -FilePath $outputFilePath -Encoding UTF8

# Output location to the console
Write-Output "System overview written to: $outputFilePath"
