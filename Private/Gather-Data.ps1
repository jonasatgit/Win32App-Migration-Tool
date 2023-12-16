Function Gather-Data {

    param (
    [Parameter(Mandatory = $false, ValuefromPipeline = $false, HelpMessage = "The component (script name) passed as LogID to the 'Write-Log' function")]
    [string]$LogId = $($MyInvocation.MyCommand).Name,
    [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0, HelpMessage = 'The name of the application to export the icon for')]
    [string]$Data
    )
    process {
    
        Switch ($GetDetectData.Type) {
            "ScriptRegistry" {
                Switch ($GetDetectData.DetectionParam) {
                    "Existence" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleRegistry -Existence -Check32BitOn64System 1 -KeyPath $GetDetectData.KeyPath -ValueName $GetDetectData.ValueName -DetectionType $GetDetectData.DetectionType
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleRegistry -Existence -Check32BitOn64System 0 -KeyPath $GetDetectData.KeyPath -ValueName $GetDetectData.ValueName -DetectionType $GetDetectData.DetectionType
                        }
                    }
                    "StringComparison" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleRegistry -StringComparison -StringComparisonOperator $GetDetectData.StringComparisonOperator -StringComparisonValue $GetDetectData.StringComparisonValue -Check32BitOn64System 1 -KeyPath $GetDetectData.KeyPath -ValueName $GetDetectData.ValueName
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleRegistry -StringComparison -StringComparisonOperator $GetDetectData.StringComparisonOperator -StringComparisonValue $GetDetectData.StringComparisonValue -Check32BitOn64System 0 -KeyPath $GetDetectData.KeyPath -ValueName $GetDetectData.ValueName
                        }
                    }
                    "IntegerComparison" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleRegistry -IntegerComparison -IntegerComparisonOperator $GetDetectData.IntegerComparisonOperator -IntegerComparisonValue $GetDetectData.IntegerComparisonValue -Check32BitOn64System 1 -KeyPath $GetDetectData.KeyPath -ValueName $GetDetectData.ValueName
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleRegistry -IntegerComparison -IntegerComparisonOperator $GetDetectData.IntegerComparisonOperator -IntegerComparisonValue $GetDetectData.IntegerComparisonValue -Check32BitOn64System 0 -KeyPath $GetDetectData.KeyPath -ValueName $GetDetectData.ValueName
                        }

                    }
                    "VersionComparison" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleRegistry -VersionComparison -VersionComparisonOperator $GetDetectData.VersionComparisonOperator -VersionComparisonValue $GetDetectData.VersionComparisonValue -Check32BitOn64System 1 -KeyPath $GetDetectData.KeyPath -ValueName $GetDetectData.ValueName
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleRegistry -VersionComparison -VersionComparisonOperator $GetDetectData.VersionComparisonOperator -VersionComparisonValue $GetDetectData.VersionComparisonValue -Check32BitOn64System 0 -KeyPath $GetDetectData.KeyPath -ValueName $GetDetectData.ValueName
                        }

                    }
                        }
            }
            "ScriptMSI" {
                $DetectionRuleFile = New-IntuneWin32AppDetectionRuleMSI -ProductCode $GetDetectData.productcode -ProductVersionOperator $GetDetectData.ProductVersionOperator -ProductVersion $GetDetectData.ProductVersion
            }
            "ScriptFileSystemFile" {
                Switch ($GetDetectData.DetectionParam) {
                    "Existence" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Existence -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 1 -DetectionType $GetDetectData.DetectionType
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Existence -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 0 -DetectionType $GetDetectData.DetectionType
                        }

                    }
                    "DateModified" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -DateModified -Operator $GetDetectData.Operator -DateTimeValue $GetDetectData.DateValueString -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 1
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -DateModified -Operator $GetDetectData.Operator -DateTimeValue $GetDetectData.DateValueString -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 0
                        }
                    }
                    "DateCreated" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -DateCreated -Operator $GetDetectData.Operator -DateTimeValue $GetDetectData.DateValueString -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 1
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -DateCreated -Operator $GetDetectData.Operator -DateTimeValue $GetDetectData.DateValueString -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 0
                        }
                    }
                    "Version" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Version -Operator $GetDetectData.Operator -VersionValue $GetDetectData.VersionValue -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 1
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Version -Operator $GetDetectData.Operator -VersionValue $GetDetectData.VersionValue -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 0
                        }
                    }
                    "Size" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Size -Operator $GetDetectData.Operator -SizeInMBValue $GetDetectData.SizeInMBValue -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 1
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Size -Operator $GetDetectData.Operator -SizeInMBValue $GetDetectData.SizeInMBValue -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 0
                        }
                    }
                }
            }
            "ScriptFileSystemFolder" {
                Switch ($GetDetectData.DetectionParam) {
                    "Existence" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Existence -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 1 -DetectionType $GetDetectData.DetectionType
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Existence -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 0 -DetectionType $GetDetectData.DetectionType
                        }

                    }
                    "DateModified" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -DateModified -Operator $GetDetectData.Operator -DateTimeValue $GetDetectData.DateValueString -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 1
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -DateModified -Operator $GetDetectData.Operator -DateTimeValue $GetDetectData.DateValueString -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 0
                        }
                    }
                    "DateCreated" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -DateCreated -Operator $GetDetectData.Operator -DateTimeValue $GetDetectData.DateValueString -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 1
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -DateCreated -Operator $GetDetectData.Operator -DateTimeValue $GetDetectData.DateValueString -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 0
                        }
                    }
                    "Version" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Version -Operator $GetDetectData.Operator -VersionValue $GetDetectData.VersionValue -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 1
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Version -Operator $GetDetectData.Operator -VersionValue $GetDetectData.VersionValue -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 0
                        }
                    }
                    "Size" {
                        If ($CB32) {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Size -Operator $GetDetectData.Operator -SizeInMBValue $GetDetectData.SizeInMBValue -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 1
                        }
                        Else {
                            $DetectionRuleFile = New-IntuneWin32AppDetectionRuleFile -Size -Operator $GetDetectData.Operator -SizeInMBValue $GetDetectData.SizeInMBValue -Path $GetDetectData.Path -FileOrFolder $GetDetectData.FileOrFolder -Check32BitOn64System 0
                        }
                    }
                }
            }
            "MSI" {
                $DetectionRuleFile = New-IntuneWin32AppDetectionRuleMSI -ProductCode $GetDetectData.productcode -ProductVersionOperator $GetDetectData.ProductVersionOperator -ProductVersion $GetDetectData.ProductVersion
            }
            "ScriptScript" {
                If ($CB32) {
                    $DetectionRuleFile = New-IntuneWin32AppDetectionRuleScript -ScriptFile $GetDetectData.ScriptFile -EnforceSignatureCheck $GetDetectData.EnforceSignatureCheck -RunAs32Bit 1
                }
                Else {
                    $DetectionRuleFile = New-IntuneWin32AppDetectionRuleScript -ScriptFile $GetDetectData.ScriptFile -EnforceSignatureCheck $GetDetectData.EnforceSignatureCheck -RunAs32Bit 0
                }
            }
        }
    Return $DetectionRuleFile
    }
}

