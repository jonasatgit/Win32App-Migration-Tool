function Get-CCAppDetectionDetails {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 2, HelpMessage = 'The name of the application to search for. Accepts wildcards *')]
        [string]$ApplicationID,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 2, HelpMessage = 'The name of the application to search for. Accepts wildcards *')]
        [string]$FilePath
    )

    #Need to check on moving this out of a hardcoded arrangement
    $apps = get-cmapplication -Id $ApplicationID

    Foreach ($App in $Apps) {
        $PackageXML = [xml]$App.SDMPackageXML
        $DTs = $PackageXML.AppMgmtDigest.DeploymentType
        if (-not [string]::IsNullOrEmpty($DTs)) {
            foreach ($DT in $DTs) {

            #Region Detection Methods
            If ($DT.Installer.DetectAction.Provider -eq 'Script') {
                #Script Detection Method
                $DTSection = "Script Detection Method"
                $DMScriptType = $DT.Installer.DetectAction.Args.Arg[1].'#text'
                $DM3264 = $DT.Installer.DetectAction.Args.Arg[3].'#text'
                Switch ($DMScriptType) {
                    0 { $DMScriptType = 'Powershell' }
                    1 { $DMScriptType = 'VBScript' }
                    2 { $DMScriptType = 'JScript' }
                }
                $DTListData = $DMScriptType
                
                If ($HideScript -eq $true) {
                }
                else {
                    $DMScriptText = $DT.Installer.DetectAction.Args.Arg[2].'#text'

                    Switch ($DMScriptType) {
                        "PowerShell" { 
                            $ScriptData = $DT.Installer.DetectAction.Args.Arg[2].'#text'
                            Out-File -FilePath "$workingFolder_Root\ScriptExport\$($App.LocalizedDisplayName).ps1" -InputObject $ScriptData
                            $DTListData += "::Detection Script Exported;Path::$($workingFolder_Root)\ScriptExport\$($App.LocalizedDisplayName).ps1"
                            $DTListData += ";Run3264::$($DM3264)"
                        }
                        "VBScript" {
                            $ScriptData = $DT.Installer.DetectAction.Args.Arg[2].'#text'
                            Out-File -FilePath "$workingFolder_Root\ScriptExport\$($App.LocalizedDisplayName).vbs" -InputObject $ScriptData
                            $DTListData += "::Detection Script Exported;Path::$($workingFolder_Root)\ScriptExport\$($App.LocalizedDisplayName).vbs"
                            $DTListData += ";Run3264::$($DM3264)"
                        }
                        "JavaScript" {
                            $ScriptData = $DT.Installer.DetectAction.Args.Arg[2].'#text'
                            Out-File -FilePath "$workingFolder_Root\ScriptExport\$($App.LocalizedDisplayName).js" -InputObject $ScriptData
                            $DTListData += "::Detection Script Exported;Path::$($workingFolder_Root)\ScriptExport\$($App.LocalizedDisplayName).js"
                            $DTListData += ";Run3264::$($DM3264)"
                        }
                    }
                }
            }
                ElseIf ($DT.Installer.DetectAction.Provider -eq 'MSI') {
                    #This is a vanilla msi detection, with no changes.  If changes are made to the detection, it will become an enhanced detection.
                    $ProductCode = ($DT.Installer.DetectAction.Args.Arg | Where-Object { $_.Name -Eq 'ProductCode' }).'#text'
                    If ($ProductCode -match '\{[0-F]{8}\-[0-F]{4}\-[0-F]{4}\-[0-F]{4}\-[0-F]{12}\}') {
                        $DTSection = "MSI Detection Method"
                        $DTListData = "MSI exists."
                    }
                }
                Else {
                    #Process Enhanced detection method.
                    $DTSection = "Enhanced Detection Method"
                    $EDMs = [xml]$DT.Installer.CustomData.EnhancedDetectionMethod.OuterXml
                    $HashedEDMs = Get-FilterEDM -EnhansedDetectionMethods $EDMs -RuleExpression $EDMs.EnhancedDetectionMethod.Rule.Expression
                    $EDMHtml = Write-EDMs -EDMHash $HashedEDMs
                    $DTListData = $EDMHtml# | Out-String
                    $EDMHtml = $Null
                }
            }
        }
    }
}
