<#
.Synopsis
Created on:   14/03/2021
Created by:   Ben Whitmore
Updated on:   12/15/2023
Updated by:   Casey Clifton
Updated on:   14/05/2024
Updated by:   https://github.com/jonasatgit

Did some changes to module install and Graph auth

Filename:     New-Win32App.ps1

The Win32 App Migration Tool is designed to inventory ConfigMgr Applications and Deployment Types, build .intunewin files and create Win3Apps in The Intune Admin Center.

.Description
**Version 3.0 BETA**  

.PARAMETER LogId
The component (script name) passed as LogID to the 'Write-Log' function.

.PARAMETER AppName
Pass a string to the toll to search for applications in ConfigMgr

.PARAMETER DownloadContent
When passed, the content for the deployment type is saved locally to the working folder "Content"

.PARAMETER SiteCode
Specify the Sitecode you wish to connect to

.PARAMETER ProviderMachineName
Specify the Site Server to connect to

.PARAMETER ExportIcon
When passed, the Application icon is decoded from base64 and saved to the Logos folder

.PARAMETER WorkingFolder
This is the working folder for the Win32AppMigration Tool. 
Note: Care should be given when specifying the working folder because downloaded content can increase the working folder size considerably

.PARAMETER PackageApps
Pass this parameter to package selected apps in the .intunewin format.
This is REQUIRED to upload to Intune

.PARAMETER CreateApps
Pass this parameter to create the Win32apps in Intune

.PARAMETER ResetLog
Pass this parameter to reset the log file

.PARAMETER ExcludePMPC
Pass this parameter to exclude apps created by PMPC from the results. Filter is applied to Application "Comments". string can be modified in Get-AppList Function

.PARAMETER ExcludeFilter
Pass this parameter to exclude specific apps from the results. string value that accepts wildcards e.g. "Microsoft*"

.PARAMETER Win32ContentPrepToolUri
URI for Win32 Content Prep Tool

.PARAMETER OverrideIntuneWin32FileName
Override intunewin filename. Default is the name calcualted from the install command line. You only need to pass the file name, not the extension

.EXAMPLE
New-Win32App -SiteCode "BB1" -ProviderMachineName "SCCM1.byteben.com" -AppName "Microsoft Edge Chromium *"

.EXAMPLE
New-Win32App -SiteCode "BB1" -ProviderMachineName "SCCM1.byteben.com" -AppName "Microsoft Edge Chromium *" -DownloadContent

.EXAMPLE
New-Win32App -SiteCode "BB1" -ProviderMachineName "SCCM1.byteben.com" -AppName "Microsoft Edge Chromium *" -ExportLogo

.EXAMPLE
New-Win32App -SiteCode "BB1" -ProviderMachineName "SCCM1.byteben.com" -AppName "Microsoft Edge Chromium *" -ExportLogo -PackageApps

.EXAMPLE
New-Win32App -SiteCode "BB1" -ProviderMachineName "SCCM1.byteben.com" -AppName "Microsoft Edge Chromium *" -ExportLogo -PackageApps -CreateApps

.EXAMPLE
New-Win32App -SiteCode "BB1" -ProviderMachineName "SCCM1.byteben.com" -AppName "Microsoft Edge Chromium *" -ExportLogo -PackageApps -CreateApps -ResetLog

.EXAMPLE
New-Win32App -SiteCode "BB1" -ProviderMachineName "SCCM1.byteben.com" -AppName "Microsoft Edge Chromium *" -ExportLogo -PackageApps -CreateApps -ResetLog -ExcludePMPC

.EXAMPLE
New-Win32App -SiteCode "BB1" -ProviderMachineName "SCCM1.byteben.com" -AppName "Microsoft Edge Chromium *" -ExportLogo -PackageApps -CreateApps -ResetLog -ExcludePMPC -ExcludeFilter "Microsoft*"

.EXAMPLE
New-Win32App -SiteCode "BB1" -ProviderMachineName "SCCM1.byteben.com" -AppName "Microsoft Edge Chromium *" -ExportLogo -PackageApps -CreateApps -ResetLog -ExcludePMPC -ExcludeFilter "Microsoft*" -OverrideIntuneWin32FileName "application"
#>
function New-Win32App {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, ValuefromPipeline = $false, HelpMessage = "The component (script name) passed as LogID to the 'Write-Log' function")]
        [string]$LogId = $($MyInvocation.MyCommand).Name,
        [Parameter(Mandatory = $True, Position = 0, HelpMessage = 'The Site Code of the ConfigMgr Site')]
        [ValidatePattern('(?##The Site Code must be only 3 alphanumeric characters##)^[a-zA-Z0-9]{3}$')]
        [string]$SiteCode,
        [Parameter(Mandatory = $True, Position = 1, HelpMessage = 'Server name that has an SMS Provider site system role')]
        [string]$ProviderMachineName,  
        [Parameter(Mandatory = $True, Position = 2, HelpMessage = 'The name of the application to search for. Accepts wildcards *')]
        [string]$AppName,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'DownloadContent: When passed, the content for the deployment type is saved locally to the working folder "Content"')]
        [Switch]$DownloadContent,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'ExportIcon: When passed, the Application icon is decoded from base64 and saved to the Logos folder')]
        [Switch]$ExportIcon,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 3, HelpMessage = 'The working folder for the Win32AppMigration Tool. Care should be given when specifying the working folder because downloaded content can increase the working folder size considerably')]
        [string]$workingFolder,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'PackageApps: Pass this parameter to package selected apps in the .intunewin format')]
        [Bool]$PackageApps = $True,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'CreateApps: Pass this parameter to create the Win32apps in Intune')]
        [Switch]$CreateApps,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'ResetLog: Pass this parameter to reset the log file')]
        [Switch]$ResetLog,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'ExcludePMPC: Pass this parameter to exclude apps created by PMPC from the results. Filter is applied to Application "Comments". string can be modified in Get-AppList Function')]
        [Switch]$ExcludePMPC,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 4, HelpMessage = 'ExcludeFilter: Pass this parameter to exclude specific apps from the results. string value that accepts wildcards e.g. "Microsoft*"')]
        [string]$ExcludeFilter,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'NoOGV: When passed, the Out-Gridview is suppressed')]
        [Switch]$NoOgv,
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 5, HelpMessage = 'URI for Win32 Content Prep Tool')]
        [string]$Win32ContentPrepToolUri = 'https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe',
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 6, HelpMessage = 'Override intunewin filename. Default is the name calcualted from the install command line')]
        [string]$OverrideIntuneWin32FileName,
        [Parameter(Mandatory = $False, Position = 7, HelpMessage = 'Add a default publisher in case the application does not have one.')]
        [string]$Publisher = 'Default',
        [Parameter(Mandatory = $False, Position = 8, HelpMessage = 'Add a default description in case the application does not have one.')]
        [string]$Description = 'Default',
        [Parameter(Mandatory = $false, Position = 9, HelpMessage = 'The Tenant ID of the Azure AD Tenant')]
        [string]$TenantID,
        [Parameter(Mandatory = $false, Position = 10, HelpMessage = 'UploadtoIntune: Pass this parameter to upload your app to Intune.')]
        [Switch]$UploadtoIntune,
        [Parameter(Mandatory = $false, Position = 11, HelpMessage = 'EntraIDAppID: ID of Entra App to get access token from')]
        [string]$EntraIDAppID = '14d82eec-204b-4c2f-b7e8-296a70dab67e' # <- "Microsoft Graph Command Line Tools"

    )

    if ([string]::IsNullOrEmpty($workingFolder))
    {
        $workingFolder = '{0}\Win32AppMigrationTool' -f $PSScriptRoot
    }

    # Validate path and create if not there yet
    if (-not (Test-Path $workingFolder)) 
    {
        New-Item -ItemType Directory -Path $workingFolder -Force | Out-Null
    }

    # Create global variable(s) 
    $global:workingFolder_Root = $workingFolder

    #region Prepare_Workspace
    # Initialize folders to prepare workspace for logging
    Write-Host "Initializing required folders..." -ForegroundColor Cyan

    foreach ($folder in $workingFolder_Root, "$workingFolder_Root\Logs") {
        if (-not (Test-Path -Path $folder)) {
            Write-Host ("Working folder root does not exist at '{0}'. Creating environemnt..." -f $folder) -ForegroundColor Cyan
            New-Item -Path $folder -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        else {
            Write-Host ("Folder '{0}' already exists. Skipping folder creation" -f $folder) -ForegroundColor Yellow
        }
    }

    # Rest the log file if the -ResetLog parameter is passed
    if ($ResetLog -and (Test-Path -Path "$workingFolder_Root\Logs") ) {
        Write-Log -Message $null -ResetLogFile
    }
    #endregion


    Write-Log -Message "Checking to see if the current session is elevated"  -LogId $LogId
    Write-Host "Checking to see if the current session is elevated" -ForegroundColor Yellow

    #region admin rights
    #Ensure that the Script is running with elevated permissions
    if(-not ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Write-Warning 'The process needs admin rights to run. Please re-run the process with admin rights.' 
        Read-Host -Prompt "Press any key to exit"
        Exit 0 
    }
    else 
    {
        Write-Host "Session is elevated" -ForegroundColor Gray
    }
    #endregion

    $listOfRequiredModules = [ordered]@{
        'Microsoft.Graph.Authentication' = ''
        #'MSAL.PS'  # Will be installed with forIntuneWin32App
        'IntuneWin32App' = ''
    }


    #region Import nuget before anyting else
    [version]$minimumVersion = '2.8.5.201'
    $nuget = Get-PackageProvider -ErrorAction Ignore | Where-Object {$_.Name -ieq 'nuget'} # not using -name parameter du to autoinstall question
    if (-Not($nuget))
    {   
        Write-Host "Need to install NuGet" -ForegroundColor Gray
        # Changed to MSI installer as the old way could not be enforced and needs to be approved by the user
        # Install-PackageProvider -Name NuGet -MinimumVersion $minimumVersion -Force
        $null = Find-PackageProvider -Name NuGet -ForceBootstrap -IncludeDependencies -MinimumVersion $minimumVersion -Force
    }


    # Install and or import modules 
    $listOfInstalledModules = Get-InstalledModule -ErrorAction SilentlyContinue
    foreach ($module in $listOfRequiredModules.GetEnumerator())
    {   
        if (-NOT($listOfInstalledModules | Where-Object {$_.Name -ieq $module.Name}))    
        {   
            Write-Host "Need to install $($module.Name)" -ForegroundColor Gray 
            #Write-Host "Module $($module.Name) not installed yet. Will be installed"
            if (-NOT([string]::IsNullOrEmpty($module.Value)))
            {
                Install-Module $module.Name -Force -RequiredVersion $module.Value
            }
            else 
            {
                Install-Module $module.Name -Force
            }               
        }     
    }

    
       
    #I like my path to return to its original location post script execution
    $StartingPoint = get-location

    # Begin Script
    New-VerboseRegion -Message 'Start Win32AppMigrationTool' -ForegroundColor 'Gray'

    $ScriptRoot = $PSScriptRoot
    Write-Log -Message ("ScriptRoot is '{0}'" -f $ScriptRoot) -LogId $LogId

    # Connect to Site Server
    Connect-SiteServer -SiteCode  $SiteCode -ProviderMachineName $ProviderMachineName

    # Check the folder structure for the working directory and create if necessary
    New-VerboseRegion -Message 'Checking Win32AppMigrationTool folder structure' -ForegroundColor 'Gray'

    #region Create_Folders
    Write-Host "Creating additional folders..." -ForegroundColor Cyan
    Write-Log -Message ("New-FolderToCreate -Root '{0}' -FolderNames @('Icons', 'Content', 'ContentPrepTool', 'Details', 'Win32Apps','ScriptExport')" -f $workingFolder_Root) -LogId $LogId
    New-FolderToCreate -Root $workingFolder_Root -FolderNames @('Icons', 'Content', 'ContentPrepTool', 'Details', 'Win32Apps', 'ScriptExport')
    #endRegion

    #region Get_Content_Tool
    New-VerboseRegion -Message 'Checking if the Win32contentpreptool is required' -ForegroundColor 'Gray'

    # Download the Win32 Content Prep Tool if the PackageApps parameter is passed
    if ($PackageApps) {
        Write-Host "Downloading the Win32contentpreptool..." -ForegroundColor Cyan
        if (Test-Path (Join-Path -Path "$workingFolder_Root\ContentPrepTool" -ChildPath "IntuneWinAppUtil.exe")) {
            Write-Log -Message ("Information: IntuneWinAppUtil.exe already exists at '{0}'. Skipping download" -f "$workingFolder_Root\ContentPrepTool") -LogId $LogId -Severity 2
            Write-Host ("Information: IntuneWinAppUtil.exe already exists at '{0}'. Skipping download" -f "$workingFolder_Root\ContentPrepTool") -ForegroundColor Yellow
        }
        else {
            Write-Log -Message ("Get-FileFromInternet -URI '{0} -Destination {1}" -f $Win32ContentPrepToolUri, "$workingFolder_Root\ContentPrepTool") -LogId $LogId
            Get-FileFromInternet -Uri $Win32ContentPrepToolUri -Destination "$workingFolder_Root\ContentPrepTool"
        }
    } 
    else {
        Write-Log -Message "The 'PackageApps' parameter was not passed. Skipping downloading of the Win32 Content Prep Tool" -LogId $LogId -Severity 2
        Write-Host "The 'PackageApps' parameter was not passed. Skipping downloading of the Win32 Content Prep Tool" -ForegroundColor Yellow
    }
    #endRegion


    #region Display_Application_Results
    New-VerboseRegion -Message 'Filtering application results' -ForegroundColor 'Gray'

    # Build a hash table of switch parameters to pass to the Get-AppList function
    $paramsToPassApp = @{}
    if ($ExcludePMPC) {
        $paramsToPassApp.Add('ExcludePMPC', $true) 
        Write-Log -Message "The ExcludePMPC parameter was passed. Ignoring all PMPC created applications" -LogId $LogId -Severity 2
        Write-Host "The ExcludePMPC parameter was passed. Ignoring all PMPC created applications" -ForegroundColor Cyan
    }
    if ($ExcludeFilter) {
        $paramsToPassApp.Add('ExcludeFilter', $ExcludeFilter) 
        Write-Log -Message ("The 'ExcludeFilter' parameter was passed. Ignoring applications that match '{0}'" -f $ExcludeFilter) -LogId $LogId -Severity 2
        Write-Host ("The 'ExcludeFilter' parameter was passed. Ignoring applications that match '{0}'" -f $ExcludeFilter) -ForegroundColor Cyan
    }
    if ($NoOGV) {
        $paramsToPassApp.Add('NoOGV', $true) 
        Write-Log -Message "The 'NoOgv' parameter was passed. Suppressing Out-GridView" -LogId $LogId -Severity 2   
        Write-Host "The 'NoOgv' parameter was passed. Suppressing Out-GridView" -ForegroundColor Cyan
    }

    Write-Log -Message ("Running function 'Get-AppList' -AppName '{0}'" -f $AppName) -LogId $LogId
    Write-Host ("Running function 'Get-AppList' -AppName '{0}'" -f $AppName) -ForegroundColor Cyan

    $applicationName = Get-AppList -AppName $AppName @paramsToPassApp
 
    # ApplicationName(s) returned from the Get-AppList function
    if ($applicationName) {
        Write-Log -Message "The Win32App Migration Tool will process the following applications:" -LogId $LogId
        Write-Host "The Win32App Migration Tool will process the following applications:" -ForegroundColor Cyan
        
        foreach ($application in $ApplicationName) {
            Write-Log -Message ("Id = '{0}', Name = '{1}'" -f $application.Id, $application.LocalizedDisplayName) -LogId $LogId
            Write-Host ("Id = '{0}', Name = '{1}'" -f $application.Id, $application.LocalizedDisplayName) -ForegroundColor Green
        }
    }
    else {
        Write-Log -Message ("There were no applications found that match the crieria '{0}' or the Out-GrideView was closed with no selection made. Cannot continue" -f $AppName) -LogId $LogId -Severity 3
        Write-Warning -Message ("There were no applications found that match the crieria '{0}' or the Out-GrideView was closed with no selection made. Cannot continue" -f $AppName)
        Get-ScriptEnd
    }
        
    #endRegion

    #region Get_App_Details
    New-VerboseRegion -Message 'Getting application details' -ForegroundColor 'Gray'

    # Calling function to grab application details
    Write-Log -Message "Calling 'Get-AppInfo' function to grab application details" -LogId $LogId
    Write-Host "Calling 'Get-AppInfo' function to grab application details" -ForegroundColor Cyan

    $app_Array = Get-AppInfo -ApplicationName $applicationName
    #endregion

    #region Get_DeploymentType_Details
    New-VerboseRegion -Message 'Getting deployment type details' -ForegroundColor 'Gray'

    # Calling function to grab deployment types details
    Write-Log -Message "Calling 'Get-CCDeploymentTypeInfo' function to grab deployment type details" -LogId $LogId
    Write-Host "Calling 'Get-CCDeploymentTypeInfo' function to grab deployment type details" -ForegroundColor Cyan
    
    $deploymentTypes_Array = foreach ($app in $app_Array) {
        Get-CCDeploymentTypeInfo -ApplicationId $Application.Id
    }

    Write-Log -Message "Creating DetectionMethodArray to hold detection methods." -LogId $LogId
    ## Creating Array with Detection Methods
    ##This data is coming from Get-CCDeploymentTypeInfo being returned as $deploymenttypes
    $DetectionMethodArray = @()
    $DetectionMethodArray += $DetectMethod0
    If ($DetectMethod1) { $DetectionMethodArray += $DetectMethod1 }
    If ($DetectMethod2) { $DetectionMethodArray += $DetectMethod2 }
    If ($DetectMethod3) { $DetectionMethodArray += $DetectMethod3 }
    If ($DetectMethod4) { $DetectionMethodArray += $DetectMethod4 }
    If ($DetectMethod5) { $DetectionMethodArray += $DetectMethod5 }
    If ($DetectMethod6) { $DetectionMethodArray += $DetectMethod6 }
    If ($DetectMethod7) { $DetectionMethodArray += $DetectMethod7 }
    If ($DetectMethod8) { $DetectionMethodArray += $DetectMethod8 }
    If ($DetectMethod9) { $DetectionMethodArray += $DetectMethod9 }
    #endregion

    #region Get_DeploymentType_Content
    New-VerboseRegion -Message 'Getting deployment type content information' -ForegroundColor 'Gray'
  
    # Calling function to grab deployment type content information
    Write-Log -Message "Calling 'Get-ContentFiles' function to grab deployment type content" -LogId $LogId
    Write-Host "Calling 'Get-ContentFiles' function to grab deployment type content" -ForegroundColor Cyan
            
    $content_Array = foreach ($deploymentType in $deploymentTypes_Array) { 
        
        # Build or reset a hash table of switch parameters to pass to the Get-ContentFiles function
        $paramsToPassContent = @{}
        
        if ($deploymentType.InstallContent) { $paramsToPassContent.Add('InstallContent', $deploymentType.InstallContent) }
        # I've found some apps don't have this setting populated so we are setting SameAsInstall if Null
        if ($Null -eq $deploymentType.UninstallSetting) { 
            $paramsToPassContent.Add('UninstallSetting', "SameAsInstall")
            Write-Log "UninstallSetting was null. Setting to SameAsInstall" -LogId $LogId -Severity 2
        }
        else {
            $paramsToPassContent.Add('UninstallSetting', $deploymentType.UninstallSetting)
        }
        if ($deploymentType.UninstallContent) { $paramsToPassContent.Add('UninstallContent', $deploymentType.UninstallContent) }
        $paramsToPassContent.Add('ApplicationId', $deploymentType.Application_Id)
        $paramsToPassContent.Add('ApplicationName', $deploymentType.ApplicationName)
        $paramsToPassContent.Add('DeploymentTypeLogicalName', $deploymentType.LogicalName)
        $paramsToPassContent.Add('DeploymentTypeName', $deploymentType.Name)
        $paramsToPassContent.Add('InstallCommandLine', $deploymentType.InstallCommandLine)

        # If we have content, call the Get-ContentInfo function
        if ($deploymentType.InstallContent -or $deploymentType.UninstallContent) { Get-ContentInfo @paramsToPassContent }
    }

    # If $DownloadContent was passed, download content to the working folder
    New-VerboseRegion -Message 'Copying content files' -ForegroundColor 'Gray'

    if ($DownloadContent) {
        Write-Log -Message "The 'DownloadContent' parameter passed" -LogId $LogId

        foreach ($content in $content_Array) {
            Get-ContentFiles -Source $content.Install_Source -Destination $content.Install_Destination

            # If the uninstall content is different to the install content, copy that too
            if ($content.Uninstall_Setting -eq 'Different') {
                Get-ContentFiles -Source $content.Uninstall_Source -Destination $content.Uninstall_Destination -Flags 'UninstallDifferent'
            }
        }  
    }
    else {
        Write-Log -Message "The 'DownloadContent' parameter was not passed. Skipping content download" -LogId $LogId -Severity 2
        Write-Host "The 'DownloadContent' parameter was not passed. Skipping content download" -ForegroundColor Yellow
    }
    #endregion

    Set-Location $startingpoint
    
    #region Exporting_Csv data
    # Export $DeploymentTypes to CSV for reference
    New-VerboseRegion -Message 'Exporting collected data to Csv' -ForegroundColor 'Gray'
    $detailsFolder = (Join-Path -Path $workingFolder_Root -ChildPath 'Details')

    Write-Log -Message ("Destination folder will be '{0}\Details" -f $workingFolder_Root) -LogId $LogId -Severity 2
    Write-Host ("Destination folder will be '{0}\Details" -f $workingFolder_Root) -ForegroundColor Cyan

    # Export application information to CSV for reference
    Export-CsvDetails -Name 'Applications' -Data $app_Array -Path $detailsFolder
    $appfile = $detailsFolder + '\Applications.csv'

    # Export deployment type information to CSV for reference
    Export-CsvDetails -Name 'DeploymentTypes' -Data $deploymentTypes_Array -Path $detailsFolder
    $dtfile = $detailsFolder + '\DeploymentTypes.csv'

    # Export content information to CSV for reference
    Export-CsvDetails -Name 'Content' -Data $content_Array -Path $detailsFolder
    $sourcefile = $detailsFolder + '\Content.csv'
    #endregion

    #region Exporting_Logos
    # Export icon(s) for the applications
    New-VerboseRegion -Message 'Exporting icon(s)' -ForegroundColor 'Gray'

    if ($ExportIcon) {
        Write-Log -Message "The 'ExportIcon' parameter passed" -LogId $LogId

        foreach ($applicationIcon in $app_Array) {
            If (!($Null -eq $applicationIcon.IconPath)) {
                Write-Log -Message ("Exporting icon for '{0}' to '{1}'" -f $applicationIcon.Name, $applicationIcon.IconPath) -Logid $LogId
                Write-Host ("Exporting icon for '{0}' to '{1}'" -f $applicationIcon.Name, $applicationIcon.IconPath) -ForegroundColor Cyan

                Export-Icon -AppName $applicationIcon.Name -IconPath $applicationIcon.IconPath -IconData $applicationIcon.IconData
            }
        }
    }
    else {
        Write-Log -Message "The 'ExportIcon' parameter was not passed. Skipping icon export" -LogId $LogId -Severity 2
        Write-Host "The 'ExportIcon' parameter was not passed. Skipping icon export" -ForegroundColor Yellow
    }
    #endregion

    #region Package_Apps
    if ($PackageApps) {

        # If the $PackageApps parameter was passed. Use the Win32Content Prep Tool to build Intune.win files
        Write-Log -Message "The 'PackageApps' Parameter passed" -LogId $LogId
        New-VerboseRegion -Message 'Creating intunewin file(s)' -ForegroundColor 'Gray'

        foreach ($content in $content_Array) {

            Write-Log -Message ("Working on application '{0}'..." -f $content.Application_Name) -LogId $LogId
            Write-Host ("`nWorking on application '{0}'..." -f $content.Application_Name) -ForegroundColor Cyan

            # Create the Win32app folder for the .intunewin files
            New-FolderToCreate -Root "$workingFolder_Root\Win32Apps" -FolderNames $content.Win32app_Destination
    
            # Create intunewin files
            Write-Log -Message ("Creating intunewin file for the deployment type '{0}' for app '{1}'" -f $content.DeploymentType_Name, $content.Application_Name) -LogId $LogId
            Write-Host ("Creating intunewin file for the deployment type '{0}' for app '{1}'" -f $content.DeploymentType_Name, $content.Application_Name)  -ForegroundColor Cyan
        
            # Build parameters to splat at the New-IntuneWin function
            $paramsToPassIntuneWin = @{}
            $paramsToPassIntuneWin.Add('ContentFolder', $content.Install_Destination)
            $paramsToPassIntuneWin.Add('OutputFolder', (Join-Path -Path "$workingFolder_Root\Win32Apps" -ChildPath $content.Win32app_Destination))
            $paramsToPassIntuneWin.Add('SetupFile', $content.Install_CommandLine)
            if ($OverrideIntuneWin32FileName) { $paramsToPassIntuneWin.Add('OverrideIntuneWin32FileName', $OverrideIntuneWin32FileName) }

            # Create the .intunewin file
            New-IntuneWin @paramsToPassIntuneWin
        }
    }
    else {
        Write-Log -Message "The 'PackageApps' parameter was not passed. Intunewin files will not be created" -LogId $LogId -Severity 2
        Write-Host "The 'PackageApps' parameter was not passed. Intunewin files will not be created" -ForegroundColor Yellow
    }
    #endRegion

    #region UploadtoIntune
    If ($UploadtoIntune) {

        New-VerboseRegion -Message "Beginning Upload to Intune." -ForegroundColor 'Gray'

        Write-Log -Message "Importing CSV's and setting them to variables" -LogId $LogId
        $Defaultapps = Import-CSV $appfile
        $Defaultappssource = Import-CSV $sourcefile
        #NEED to add a loop to pick up any other lines in the csv files
        $Defaultappsdt = Import-CSV $dtfile | select-object -First 1
        $ImageFile = $Defaultapps.IconPath

        If ($Imagefile) {
            $Icon = New-IntuneWin32AppIcon -FilePath $ImageFile
        }

        #Detection Rules are hard
        $DetNum = ($Defaultappsdt | findstr /i "detectiondata").count

        Write-Log -Message "App has $($DetNum) Detection Methods." -LogId $LogId
        Write-Host "App has $($DetNum) Detection Methods."
        Write-Log -Message "Looping through each method" -LogId $LogId
        Write-Host "Looping through each method"

        ## Need to see if New-IntuneWin can handle multiple detection methods. There is a function to add addtional detection methods
        Write-Log -Message "Creating Least Restrictive Requirement Rule"  -LogId $LogId
        $RequirementRule = New-IntuneWin32AppRequirementRule -Architecture All -MinimumSupportedWindowsRelease W10_1607 -MinimumFreeDiskSpaceInMB 100 -MinimumMemoryInMB 100 -MinimumNumberOfProcessors 1 -MinimumCPUSpeedInMHz 100

        Write-Host ""
        Write-Host "Running Build-DetectionData" -ForegroundColor Magenta
        Write-Host ""

        Write-Log -Message "Calling 'GetDetectData' function to gather data for Win32App" -LogId $LogId

        #Need to add switches to Build-DetectionData            
        $GetDetectData = Build-DetectionData
        $CB32 = $GetDetectData.Check32BitOn64System

        ## Gather
        Write-Log -Message "Calling 'Gather-Data' function to gather data for Win32App" -LogId $LogId
        $DetectionRuleFile = Gather-Data -data $GetDetectData

        #$Filepath comes from New-IntuneWin (Currently requires the packageapp switch)
        Write-Log -Message "Filepath=$($IWFilePath)" -LogId $LogId
        $Filepath = $IWFilePath

        Write-Log -Message "Details for DetectionRule:"
        Write-Log -Message "Description=$($Description)" -LogId $LogId
        Write-Log -Message "Publisher=$($Publisher)" -LogId $LogId
        Write-Log -Message "DetectionRule=$($DetectionRuleFile)" -LogId $LogId
        Write-Log -Message "RequirementRule=$($RequirementRule)" -LogId $LogId

        Write-Log -Message "Checking for Install and Uninstall Command Lines" -LogId $LogId
        $InstallCommandLine = $Defaultappsdt.InstallCommandLine
        Write-Log -Message "Install Commandline is: $($InstallCommandLine)"

        # This will set a default uninstall command if one is not present in the application.
        If ($Defaultappsdt.UninstallCommandLine -eq "") {
            Write-Log "No uninstall command found. Making uninstall command equal to Install command. Manual intervention will be needed if a genuine uninstall command is needed." -LogId $LogId -Severity 2
            $UninstallCommandLine = $Defaultappsdt.InstallCommandLine
        }
        Else {
            $UninstallCommandLine = $Defaultappsdt.UninstallCommandLine
        } 
        Write-Log -Message "Uninstall Commandline is: $($UninstallCommandLine)" -LogId $LogId

        Write-Log -Message "Setting path back to scriptroot and calling Connect-MSIntuneGraph" -LogId $LogId
        Write-Host "Setting path back to scriptroot and calling Connect-MSIntuneGraph"
        Set-Location $StartingPoint

        # Connet to Graph with native PowerShell command and request DeviceManagementApps.ReadWrite.All permisson
        # If permission is not set, user will be prompted
        Connect-MgGraph -Scopes 'DeviceManagementApps.ReadWrite.All'
        Start-Sleep -Seconds 5
        # Now connect with Connect-MSIntuneGraph (required for win32app module) using the same app ID to get proper permissions
        Connect-MSIntuneGraph -TenantID $TenantID -ClientID $EntraIDAppID

        # We might need to wait for the permissions to be active
        # So lets test the token for the correct scope
        $decodedJwt = Get-DecodedJwt -token $Global:AuthenticationHeader.Authorization

        if (-not ($decodedJwt.scp -imatch 'DeviceManagementApps.ReadWrite.All'))
        {
            Write-Log -Message "Entra ID App `"$EntraIDAppID`" does not have `"DeviceManagementApps.ReadWrite.All`" permissions yet. Will wait 30 seconds" -LogId $LogId
            Start-Sleep -Seconds 30
            Connect-MSIntuneGraph -TenantID $TenantID -ClientID $EntraIDAppID -Refresh    
        }

        Write-Log -Message "Gathering Additional App Details" -LogId $LogId
        # This will set defaults for description and publisher if one is not present in the application.
        If ($Defaultapps.Description -like "" -or $null -eq $Defaultapps.Description) {
            $Description = "Default"
        }
        else {
            $Description = $Defaultapps.Description
        }
        If ($Defaultapps.Publisher -like "") {
            $Publisher = "Default"
        }
        else {
            $Publisher = $Defaultapps.Publisher
        }

        Write-Log -Message "Calling 'Add-IntuneWin32App' function to create Win32App in Intune" -LogId $LogId
        If ($Null -eq $Icon) {
            Add-IntuneWin32App -FilePath $IWFilePath -DisplayName $Defaultappsdt.ApplicationName -Description $description -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRuleFile -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Verbose
            Write-Log -Message "Add-IntuneWin32App Command:"
            Write-Log -Message 'Add-IntuneWin32App -FilePath $IWFilePath -DisplayName $Defaultappsdt.ApplicationName -Description $description -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRuleFile -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Verbose'
        }
        Else {
            Add-IntuneWin32App -FilePath $IWFilePath -DisplayName $Defaultappsdt.ApplicationName -Description $description -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRuleFile -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Icon $Icon -Verbose
            Write-Log -Message "Add-IntuneWin32App Command:"
            Write-Log -Message 'Add-IntuneWin32App -FilePath $IWFilePath -DisplayName $Defaultappsdt.ApplicationName -Description $description -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRuleFile -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Icon $Icon -Verbose'
        }
    }
    #endregion

    Get-ScriptEnd
}
