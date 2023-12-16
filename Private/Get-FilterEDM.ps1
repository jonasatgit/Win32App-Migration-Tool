Function Get-FilterEDM {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [xml]
        $EnhansedDetectionMethods,
        [Parameter(Mandatory = $true)]
        $RuleExpression,
        [Parameter(Mandatory = $false)]
        [hashtable]$DMSummary = @{}
    )
    foreach ($Expression in $RuleExpression) {
        If ($Expression.Operator -eq 'And') {
            Write-Verbose "adding an And"
            #            $DMSummary.Add('And',@{})
            if ($DMSummary.keys -notcontains 'And') {
                $DMSummary.Add('And', @())
            }
            $TheseDetails = Get-FilterEDM -EnhansedDetectionMethods $EnhansedDetectionMethods -RuleExpression $Expression.Operands.Expression
            foreach ($key in $TheseDetails.keys) {
                $DMSummary.And += @{$key = $($TheseDetails.$key) }
            }
        }
        ElseIf ($Expression.Operator -eq 'Or') {
            Write-Verbose "adding an Or"
            #            $DMSummary.Add('Or',@{})
            if ($DMSummary.keys -notcontains 'Or') {
                $DMSummary.Add('Or', @())
            }
            $TheseDetails = Get-FilterEDM -EnhansedDetectionMethods $EnhansedDetectionMethods -RuleExpression $Expression.Operands.Expression
            foreach ($key in $TheseDetails.keys) {
                $DMSummary.Or += @{$key = $($TheseDetails.$key) }
            }
        }
        Else {
            if ($DMSummary.keys -notcontains 'Settings') {
                $DMSummary.Add('Settings', @())
            }
            $SettingLogicalName = $Expression.Operands.SettingReference.SettingLogicalName
            Switch ($Expression.Operands.SettingReference.SettingSourceType) {
                'Registry' {
                    Write-Verbose "registry Setting"
                    $RegSetting = $EnhansedDetectionMethods.EnhancedDetectionMethod.Settings.SimpleSetting | Where-Object { $_.LogicalName -eq "$SettingLogicalName" }
                    $DMSummary.Settings += @{'RegSetting' = [PSCustomObject]@{
                            RegHive     = $RegSetting.RegistryDiscoverySource.Hive
                            RegKey      = $RegSetting.RegistryDiscoverySource.Key
                            RegValue    = $RegSetting.RegistryDiscoverySource.ValueName
                            Reg64Bit    = $RegSetting.RegistryDiscoverySource.Is64Bit
                            RegMethod   = $Expression.Operands.SettingReference.Method
                            RegData     = $Expression.Operands.ConstantValue.Value
                            RegDataList = $Expression.Operands.ConstantValueList.ConstantValue.Value
                            RegDataType = $Expression.Operands.SettingReference.DataType
                            RegOperator = $Expression.Operator
                        }
                    }
                }
                'File' {
                    $FileSetting = $EnhansedDetectionMethods.EnhancedDetectionMethod.Settings.File | Where-Object { $_.LogicalName -eq "$SettingLogicalName" }
                    $DMSummary.Settings += @{'FileSetting' = [PSCustomObject]@{
                            ParentFolder             = $FileSetting.Path
                            FileName                 = $FileSetting.Filter
                            File64Bit                = $FileSetting.Is64Bit
                            FileOperator             = $Expression.Operator
                            FileMethod               = $Expression.Operands.SettingReference.Method
                            FileValueList            = $Expression.Operands.ConstantValueList.ConstantValue.Value
                            FileValue                = $Expression.Operands.ConstantValue.Value
                            FilePropertyName         = $Expression.Operands.SettingReference.PropertyPath
                            FilePropertyNameDataType = $Expression.Operands.SettingReference.DataType
                        }
                    }
                }
                'Folder' {
                    $FolderSetting = $EnhansedDetectionMethods.EnhancedDetectionMethod.Settings.Folder | Where-Object { $_.LogicalName -eq "$SettingLogicalName" }
                    $DMSummary.Settings += @{'FolderSetting' = [PSCustomObject]@{
                            ParentFolder               = $FolderSetting.Path
                            FolderName                 = $FolderSetting.Filter
                            Folder64Bit                = $FolderSetting.Is64Bit
                            FolderOperator             = $Expression.Operator
                            FolderMethod               = $Expression.Operands.SettingReference.Method
                            FolderValueList            = $Expression.Operands.ConstantValueList.ConstantValue.Value
                            FolderValue                = $Expression.Operands.ConstantValue.Value
                            FolderPropertyName         = $Expression.Operands.SettingReference.PropertyPath
                            FolderPropertyNameDataType = $Expression.Operands.SettingReference.DataType
                        }
                    }
                }
                'MSI' {
                    $MSISetting = $EnhansedDetectionMethods.EnhancedDetectionMethod.Settings.MSI | Where-Object { $_.LogicalName -eq "$SettingLogicalName" }
                    if ($Expression.Operands.SettingReference.DataType -eq 'Int64') {
                        #Existensile detection
                        Write-Verbose "MSI Exists on System"
                        #$MSIDetection = "MSI Exists on System"
                    }
                    elseif ($Expression.Operands.SettingReference.DataType -eq 'Version') {
                        #Exists plus is a specific version of MSI
                        Write-Verbose "MSI Version is..."
                        #$MSIOperator = "The MSI $MSIDataType is $(Convert-EdmOperator $Expression.Operator) [$MSIVersion]."
                    }
                    Else {
                        Write-Verbose "Unknown MSI Configuration for product code."
                    }
                    $DMSummary.Settings += @{'MsiSetting' = [PSCustomObject]@{
                            MSIProductCode  = $MSISetting.ProductCode
                            MSIDataType     = $Expression.Operands.SettingReference.DataType
                            MSIMethod       = $Expression.Operands.SettingReference.Method
                            MSIDataValue    = $Expression.Operands.ConstantValue.Value
                            MSIPropertyName = $Expression.Operands.SettingReference.PropertyPath
                            MSIOperator     = $Expression.Operator
                        }
                    }
                }
            }
        }
    }
    Return $DMSummary
}
