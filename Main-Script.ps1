function Show-Menu {
    param (
        [string]$Prompt = 'Choose an option:'
    )

    Write-Host ''
    Write-Host '1) Run Default-Programs.ps1'
    Write-Host '2) Run Gamer-Programs.ps1'
    Write-Host '3) Run List-All-Programs.ps1'
    Write-Host '4) Run Uninstall-Everything.ps1'
    Write-Host '5) Run Default-Windows-Settings.ps1'
    Write-Host '0) Exit'
    Write-Host ''
    
    do {
        $choice = Read-Host $Prompt
    } while ($choice -notin '0','1','2','3','4','5')

    return $choice
}

do {
    $userChoice = Show-Menu
    switch ($userChoice) {
        '1' {
            irm https://raw.githubusercontent.com/Cameron-K03/Windows-Setup/main/Default-Programs.ps1 | iex
        }
        '2' {
            irm https://raw.githubusercontent.com/Cameron-K03/Windows-Setup/main/Gamer-Programs.ps1 | iex
        }
        '3' {
            irm https://raw.githubusercontent.com/Cameron-K03/Windows-Setup/main/List-All-Programs.ps1 | iex
        }
        '4' {
            irm https://raw.githubusercontent.com/Cameron-K03/Windows-Setup/main/Uninstall-Everything.ps1 | iex
        }
        '5' {
            irm https://raw.githubusercontent.com/Cameron-K03/Windows-Setup/main/Default-Windows-Settings.ps1 | iex
        }
        '0' {
            Write-Host 'Exiting...' -ForegroundColor Green
            break
        }
        default {
            Write-Host 'Invalid option, try again!' -ForegroundColor Red
        }
    }
} while ($userChoice -ne '0')
