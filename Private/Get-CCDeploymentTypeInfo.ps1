function Get-CCDeploymentTypeInfo {
    param (
        [Parameter(Mandatory = $false, ValuefromPipeline = $false, HelpMessage = "The component (script name) passed as LogID to the 'Write-Log' function")]
        [string]$LogId = $($MyInvocation.MyCommand).Name,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0, HelpMessage = 'The id of the application(s) to get information for')]
        [string]$ApplicationId
    )
    begin {

        # Create an empty array to store the deployment type information
        $deploymentTypes = @()
        . Get-CCAppDetectionDetails -ApplicationId $ApplicationID -FilePath $workingFolder_Root 
    }
    process {

        try {

            # Grab the SDMPackgeXML which contains the application and deployment type details
            Write-Log -Message ("Invoking Get-CMApplication where Id equals '{0}'" -f $ApplicationId) -LogId $LogId
            Write-Host ("Invoking Get-CMApplication where Id equals '{0}'" -f $ApplicationId) -ForegroundColor Cyan
            $xmlPackage = Get-CMApplication -Id $ApplicationId | Where-Object { $null -ne $_.SDMPackageXML } | Select-Object -ExpandProperty SDMPackageXML
        
            # Prepare xml from SDMPackageXML
            $xmlContent = [xml]($xmlPackage)

            # Get the total number of deployment types for the application
            $totalDeploymentTypes = ($xmlContent.AppMgmtDigest.Application.DeploymentTypes.DeploymentType | Measure-Object | Select-Object -ExpandProperty Count)
            Write-Log -Message ("The total number of deployment types for '{0}' is '{1}')" -f $xmlContent.AppMgmtDigest.Application.title.'#text', $totalDeploymentTypes) -LogId $LogId
            Write-Host ("The total number of deployment types for '{0}' is '{1}')" -f $xmlContent.AppMgmtDigest.Application.title.'#text', $totalDeploymentTypes) -ForegroundColor Cyan

            if ($totalDeploymentTypes -ge 0) {

                # If there are deployment types, iterate through each deployment type and collect the details
                foreach ($object in $xmlContent.AppMgmtDigest.DeploymentType) {

                    # Handle multiple objects if content is an array
                    if ($object.Installer.Contents.Content.Location.Count -gt 1) {
                        $installLocation = $object.Installer.Contents.Content.Location[0]
                        $uninstallLocation = $object.Installer.Contents.Content.Location[1]
                    }
                    else {
                        $installLocation = $object.Installer.Contents.Content.Location
                        $uninstallLocation = $object.Installer.Contents.Content.Location
                    }


                    # Check and see if there are multiple deployment types
                    $DMCount = ($DTListData).Count
                    Write-Host $xmlContent.AppMgmtDigest.Application.title.'#text' "Has $($DMCount) Detection Methods"

                    # Create a new custom hashtable to store Deployment type details
                    $deploymentObject = [PSCustomObject]@{}

                    # Add deployment type details to the PSCustomObject
                    $deploymentObject | Add-Member NoteProperty -Name Application_Id -Value $ApplicationId
                    $deploymentObject | Add-Member NoteProperty -Name ApplicationName -Value $xmlContent.AppMgmtDigest.Application.title.'#text'
                    $deploymentObject | Add-Member NoteProperty -Name Application_LogicalName -Value $xmlContent.AppMgmtDigest.Application.LogicalName
                    $deploymentObject | Add-Member NoteProperty -Name LogicalName -Value $Object.LogicalName
                    $deploymentObject | Add-Member NoteProperty -Name Name -Value $Object.Title.InnerText
                    $deploymentObject | Add-Member NoteProperty -Name Technology -Value $Object.Installer.Technology
                    $deploymentObject | Add-Member NoteProperty -Name ExecutionContext -Value $Object.Installer.ExecutionContext
                    $deploymentObject | Add-Member NoteProperty -Name InstallContent -Value $installLocation.TrimEnd('\') 
                    $deploymentObject | Add-Member NoteProperty -Name InstallCommandLine -Value $Object.Installer.CustomData.InstallCommandLine
                    $deploymentObject | Add-Member NoteProperty -Name UnInstallSetting -Value $Object.Installer.CustomData.UnInstallSetting
                    $deploymentObject | Add-Member NoteProperty -Name UninstallContent -Value $uninstallLocation.TrimEnd('\') 
                    $deploymentObject | Add-Member NoteProperty -Name UninstallCommandLine -Value $Object.Installer.CustomData.UninstallCommandLine
                    $deploymentObject | Add-Member NoteProperty -Name ExecuteTime -Value $Object.Installer.CustomData.ExecuteTime
                    $deploymentObject | Add-Member NoteProperty -Name MaxExecuteTime -Value $Object.Installer.CustomData.MaxExecuteTime
                    $deploymentObject | Add-Member NoteProperty -Name DetectionMethod -Value $DTSection

                    $Global:DetectMethod0 = $null
                    $Global:DetectMethod1 = $null
                    $Global:DetectMethod2 = $null
                    $Global:DetectMethod3 = $null
                    $Global:DetectMethod4 = $null
                    $Global:DetectMethod5 = $null
                    $Global:DetectMethod6 = $null
                    $Global:DetectMethod7 = $null
                    $Global:DetectMethod8 = $null
                    $Global:DetectMethod9 = $null

                    If ($DMCount -gt 1) {
                        $deploymentObject | Add-Member NoteProperty -Name DetectionData0 -Value ($DTListData)[0]
                        $Global:DetectMethod0 = ($DTListData)[0]

                        if ($($DTListData)[1]) { 
                            $deploymentObject | Add-Member NoteProperty -Name DetectionData1 -Value ($DTListData)[1] 
                            $Global:DetectMethod1 = ($DTListData)[1]
                        }
                        if ($($DTListData)[2]) { 
                            $deploymentObject | Add-Member NoteProperty -Name DetectionData2 -Value ($DTListData)[2]
                            $Global:DetectMethod2 = ($DTListData)[2]
                        }
                        if ($($DTListData)[3]) {
                            $deploymentObject | Add-Member NoteProperty -Name DetectionData3 -Value ($DTListData)[3]
                            $Global:DetectMethod3 = ($DTListData)[3]
                        }
                        if ($($DTListData)[4]) {
                            $deploymentObject | Add-Member NoteProperty -Name DetectionData4 -Value ($DTListData)[4]
                            $Global:DetectMethod4 = ($DTListData)[4]
                        }
                        if ($($DTListData)[5]) {
                            $deploymentObject | Add-Member NoteProperty -Name DetectionData5 -Value ($DTListData)[5]
                            $Global:DetectMethod5 = ($DTListData)[5]
                        }
                        if ($($DTListData)[6]) {
                            $deploymentObject | Add-Member NoteProperty -Name DetectionData6 -Value ($DTListData)[6]
                            $Global:DetectMethod6 = ($DTListData)[6]
                        }
                        if ($($DTListData)[7]) {
                            $deploymentObject | Add-Member NoteProperty -Name DetectionData7 -Value ($DTListData)[7]
                            $Global:DetectMethod7 = ($DTListData)[7]
                        }
                        if ($($DTListData)[8]) {
                            $deploymentObject | Add-Member NoteProperty -Name DetectionData8 -Value ($DTListData)[8]
                            $Global:DetectMethod8 = ($DTListData)[8]
                        }
                        if ($($DTListData)[9]) {
                            $deploymentObject | Add-Member NoteProperty -Name DetectionData9 -Value ($DTListData)[9]
                            $Global:DetectMethod9 = ($DTListData)[9]
                        }
                    }
                    Else {
                        $deploymentObject | Add-Member NoteProperty -Name DetectionData0 -Value ($DTListData)
                        $Global:DetectMethod0 = $DTListData
                    }

                    # Output the deployment type object
                    Write-Host "`n$deploymentObject`n" -ForegroundColor Green

                    # Add the deployment type object to the array
                    $deploymentTypes += $deploymentObject          
                }
            }
            else {
                Write-Log -Message ("Warning: No DeploymentTypes found for '{0}'" -f $xmlContent.AppMgmtDigest.Application.LogicalName) -LogId $LogId -Severity 2
                Write-Host ("Warning: No DeploymentTypes found for '{0}'" -f $xmlContent.AppMgmtDigest.Application.LogicalName) -ForegroundColor Yellow
            }
        
            return $deploymentTypes

        }
        catch {
            Write-Log -Message ("Could not get deployment type information for application Id '{0}'" -f $ApplicationId) -LogId $LogId -Severity 3
            Write-Warning -Message ("Could not get deployment type information for application id '{0}'" -f $ApplicationId)
            Get-ScriptEnd -LogId $LogId -Message $_.Exception.Message
        }
    }
}
