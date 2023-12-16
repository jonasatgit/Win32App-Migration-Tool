function Get-InstallCommand {

    param(
        [Parameter(Mandatory = $false, ValuefromPipeline = $false, HelpMessage = 'The component (script name) passed as LogID to the Write-Log function')]
        [string]$LogId = $($MyInvocation.MyCommand).Name,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, HelpMessage = 'The setup file to be used for packaging. Normally the .msi, .exe or .ps1 file used to install the application')]
        [string]$InstallTech,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 1, HelpMessage = 'The setup file to be used for packaging. Normally the .msi, .exe or .ps1 file used to install the application')]
        [string]$SetupFile

    )
    process {
        Write-Log -Message "Function: Get-InstallCommand was called" -Log "Main.log"

        # Search the Install Command line for the installer type
        Write-Log -Message ("'{0}' installer type was detected" -f $InstallTech) -LogId $LogId 
        Write-Host ("'{0}' installer type was detected" -f $InstallTech) -ForegroundColor Green

        # Build the command to be used with the Win32 Content Prep Tool

        If ($SetupFile -like '*"*') { $Quotes = $true } else {$quotes = $false }
        If ($quotes -eq $True) {
            Write-Host "Installer command has spaces, use content within as install command."
            $SetupFile = $SetupFile.Split('"')[1]
            $command = $SetupFile
        }
        Else {
            $right = ($SetupFile -split "$InstallTech")[0]
            $right = ($right -Split " ")[-1]
            $filename = $right.TrimStart("\", ".", "`"")
            $command = $filename + $InstallTech
        }
        

        # Verbose and log the result
        Write-Log -Message "Extracting the SetupFile Name for the Microsoft Win32 Content Prep Tool from the Install Command..." -LogId $LogId
        Write-Host "Extracting the SetupFile Name for the Microsoft Win32 Content Prep Tool from the Install Command..." -ForegroundColor Cyan
        Write-Log -Message ("The setupfile to pass to Win32ContentPrepTool is '{0}'" -f $command) -LogId $LogId
        Write-Host ("The setupfile to pass to Win32ContentPrepTool is '{0}'" -f $command) -ForegroundColor Green

        return $command
    }
}
