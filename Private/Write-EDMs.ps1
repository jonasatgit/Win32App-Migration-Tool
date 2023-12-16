Function Write-EDMs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$EDMHash,
        [switch]$Recursion
    )
    foreach ($key in $EDMHash.keys) {
        if ($key -like 'Or') {
            Write-Verbose "One of these conditions (Or)"
            foreach ($ThisOr in $EDMHash.Or) {
                if ($ThisOr.Keys -contains 'Settings') {
                    foreach ($Setting in $ThisOr.Settings) {
                        $Values = $setting.Values[0].ForEach({ $_ })[0]
                        switch ($($Setting.Keys.ForEach({ $_ })[0])) {
                            'RegSetting' {
                                $RegSetting = "RegistryKey::$($values.RegHive)\$($values.RegKey)"
                                $RegSetting += ";RegistryValueName::$($values.RegValue)"
                                If ($Values.RegDataType -eq "Boolean") {
                                    $RegSetting += ";Reg key/value::Exists"
                                }
                                else {
                                    $RegSetting += ";ValueDataType::$($Values.RegDataType)"
                                    $Operation = Convert-EdmOperator -Operator $Values.RegOperator -Data "$($Values.RegData)" -DataList $($Values.RegDataList)
                                    $RegSetting += ";Operator::" + $Operation                            
                                }
                                If ($Values.Reg64Bit -eq "false") {
                                    $RegSetting += ";3264::RegKeyAssociatedWith32-bitAppOn64-BitSystem" ##Checked
                                }

                                $RegSetting
                            }
                            'FileSetting' {
                                $FileSetting = "FileSystemFile::$($values.ParentFolder)\$($values.FileName)"
                                If ($Values.FilePropertyNameDataType -eq "Int64" -and $Values.FileMethod -eq "Count" -and $Values.FileValue -eq 0) {
                                    $FileSetting += ";Boolean::FileExists"
                                }
                                else {
                                    $FileSetting += ";FilePropertyName::$($values.FilePropertyName)"
                                    $FileSetting += ";FilePropertyDataType::$($Values.FilePropertyNameDataType)"
                                    $Operation = Convert-EdmOperator -Operator $Values.FileOperator -Data "$($Values.FileValue)" -DataList $($Values.FileValueList)
                                    $FileSetting += ";Operator::" + $Operation
                                }
                                If ($Values.File64Bit -eq "false") {
                                    $FileSetting += ";3264::FileAssociatedWith32-bitAppOn64-BitSystem" ##Checked
                                }

                                $FileSetting
                            }
                            'FolderSetting' {
                                $FolderSetting += "FileSystemFolder::$($values.ParentFolder)\$($values.FolderName)"
                                If ($Values.FolderPropertyNameDataType -eq "Int64" -and $Values.FolderMethod -eq "Count" -and $Values.FolderValue -eq 0) {
                                    $FolderSetting += ";Boolean::FolderExists"
                                }
                                else {
                                    $FolderSetting += ";FilePropertyName::$($values.FolderPropertyName)"
                                    $FolderSetting += ";FilePropertyDataType::$($Values.FolderPropertyNameDataType)"
                                    $Operation = Convert-EdmOperator -Operator $Values.FolderOperator -Data "$($Values.FolderValue)" -DataList $($Values.FolderValueList)
                                    $FolderSetting += ";Operator::" + $Operation
                                }
                                If ($Values.Folder64Bit -eq "false") {
                                    $FolderSetting += ";3264::FolderAssociatedWith32-bitAppOn64-BitSystem" ##Checked
                                }

                                $FolderSetting
                            }
                            'MsiSetting' {
                                $MsiSetting = "ProductCode::$($values.MSIProductCode)"
                                If ($Values.MSIDataType -eq "Int64" -and $Values.MSIMethod -eq "Count" -and $Values.MSIDataValue -eq 0) {
                                    $MsiSetting += ";MSIexists."
                                }
                                else {
                                    $MsiSetting += ";MSIPropertyName::$($values.MSIPropertyName)"
                                    $MsiSetting += ";MSIPropertyDataType::$($Values.MSIDataType)"
                                    $Operation = Convert-EdmOperator -Operator $Values.MSIOperator -Data "$($Values.MSIDataValue)"
                                    $MsiSetting += ";Operator::" + $Operation
                                }
                                $MsiSetting
                            }
                            Default {
                                $SettingDetails = 'UnknownDetectionSetting.'
                            }
                        }
                    }
                }
                else {
                    Write-EDMs -EDMHash $ThisOr -Recursion
                    Write-Verbose "End (Or)"
                }
            }
        }
        elseif ($key -like 'And') {
            Write-Verbose "All of these conditions (And)"
            foreach ($ThisAnd in $EDMHash.And) {
                if ($ThisAnd.Keys -contains 'Settings') {
                    foreach ($Setting in $ThisAnd.Settings) {
                        $Values = $setting.Values[0].ForEach({ $_ })[0]
                        switch ($($Setting.Keys.ForEach({ $_ })[0])) {
                            'RegSetting' {
                                $RegSetting = "RegistryKey::$($values.RegHive)\$($values.RegKey)"
                                $RegSetting += ";RegistryValueName::$($values.RegValue)"
                                If ($Values.RegDataType -eq "Boolean") {
                                    $RegSetting += ";Reg key/value::Exists"
                                }
                                else {
                                    $RegSetting += ";ValueDataType::$($Values.RegDataType)"
                                    $Operation = Convert-EdmOperator -Operator $Values.RegOperator -Data "$($Values.RegData)" -DataList $($Values.RegDataList)
                                    $RegSetting += ";Operator::" + $Operation                            
                                }
                                If ($Values.Reg64Bit -eq "false") {
                                    $RegSetting += ";3264::RegKeyAssociatedWith32-bitAppOn64-BitSystem" ##Checked
                                }
                                
                                $RegSetting
                            }
                            'FileSetting' {
                                $FileSetting = "FileSystemFile::$($values.ParentFolder)\$($values.FileName)"
                                If ($Values.FilePropertyNameDataType -eq "Int64" -and $Values.FileMethod -eq "Count" -and $Values.FileValue -eq 0) {
                                    $FileSetting += ";Boolean::FileExists"
                                }
                                else {
                                    $FileSetting += ";FilePropertyName::$($values.FilePropertyName)"
                                    $FileSetting += ";FilePropertyDataType::$($Values.FilePropertyNameDataType)"
                                    $Operation = Convert-EdmOperator -Operator $Values.FileOperator -Data "$($Values.FileValue)" -DataList $($Values.FileValueList)
                                    $FileSetting += ";Operator::" + $Operation
                                }
                                If ($Values.File64Bit -eq "false") {
                                    $FileSetting += ";3264::FileAssociatedWith32-bitAppOn64-BitSystem" ##Checked
                                }

                                $FileSetting
                            }
                            'FolderSetting' {
                                $FolderSetting += "FileSystemFolder::$($values.ParentFolder)\$($values.FolderName)"
                                If ($Values.FolderPropertyNameDataType -eq "Int64" -and $Values.FolderMethod -eq "Count" -and $Values.FolderValue -eq 0) {
                                    $FolderSetting += ";Boolean::FolderExists"
                                }
                                else {
                                    $FolderSetting += ";FilePropertyName::$($values.FolderPropertyName)"
                                    $FolderSetting += ";FilePropertyDataType::$($Values.FolderPropertyNameDataType)"
                                    $Operation = Convert-EdmOperator -Operator $Values.FolderOperator -Data "$($Values.FolderValue)" -DataList $($Values.FolderValueList)
                                    $FolderSetting += ";Operator::" + $Operation
                                }
                                If ($Values.Folder64Bit -eq "false") {
                                    $FolderSetting += ";3264::FolderAssociatedWith32-bitAppOn64-BitSystem" ##Checked
                                }

                                $FolderSetting
                            }
                            'MsiSetting' {
                                $MsiSetting = "ProductCode::$($values.MSIProductCode)"
                                If ($Values.MSIDataType -eq "Int64" -and $Values.MSIMethod -eq "Count" -and $Values.MSIDataValue -eq 0) {
                                    $MsiSetting += ";MSIexists."
                                }
                                else {
                                    $MsiSetting += ";MSIPropertyName::$($values.MSIPropertyName)"
                                    $MsiSetting += ";MSIPropertyDataType::$($Values.MSIDataType)"
                                    $Operation = Convert-EdmOperator -Operator $Values.MSIOperator -Data "$($Values.MSIDataValue)"
                                    $MsiSetting += ";Operator::" + $Operation
                                }
                                $MsiSetting
                            }
                            Default {
                                $SettingDetails = 'UnknownDetectionSetting.'
                            }
                        }
                    }
                }
                else {
                    Write-EDMs -EDMHash $ThisAnd -Recursion
                    Write-Verbose "End (And)"                        
                }
            }
        }
    }
    If (-not $Recursion.IsPresent) {
        If ($null -ne $EDMHash.Settings) {
            foreach ($Setting in $EDMHash.Settings) {
                $Values = $setting.Values[0].ForEach({ $_ })[0]
                switch ($($Setting.Keys.ForEach({ $_ })[0])) {
                    'RegSetting' {
                        $RegSetting = "RegistryKey::$($values.RegHive)\$($values.RegKey)"
                        $RegSetting += ";RegistryValueName::$($values.RegValue)"
                        If ($Values.RegDataType -eq "Boolean") {
                            $RegSetting += ";Reg key/value::Exists"
                        }
                        else {
                            $RegSetting += ";ValueDataType::$($Values.RegDataType)"
                            $Operation = Convert-EdmOperator -Operator $Values.RegOperator -Data "$($Values.RegData)" -DataList $($Values.RegDataList)
                            $RegSetting += ";Operator::" + $Operation                            
                        }
                        If ($Values.Reg64Bit -eq "false") {
                            $RegSetting += ";3264::RegKeyAssociatedWith32-bitAppOn64-BitSystem" ##Checked
                        }

                        $RegSetting
                    }
                    'FileSetting' {
                        $FileSetting = "FileSystemFile::$($values.ParentFolder)\$($values.FileName)"
                        If ($Values.FilePropertyNameDataType -eq "Int64" -and $Values.FileMethod -eq "Count" -and $Values.FileValue -eq 0) {
                            $FileSetting += ";Boolean::FileExists"
                        }
                        else {
                            $FileSetting += ";FilePropertyName::$($values.FilePropertyName)"
                            $FileSetting += ";FilePropertyDataType::$($Values.FilePropertyNameDataType)"
                            $Operation = Convert-EdmOperator -Operator $Values.FileOperator -Data "$($Values.FileValue)" -DataList $($Values.FileValueList)
                            $FileSetting += ";Operator::" + $Operation
                        }
                        If ($Values.File64Bit -eq "false") {
                            $FileSetting += ";3264::FileAssociatedWith32-bitAppOn64-BitSystem" ##Checked
                        }

                        $FileSetting
                    }
                    'FolderSetting' {
                        $FolderSetting += "FileSystemFolder::$($values.ParentFolder)\$($values.FolderName)"
                        If ($Values.FolderPropertyNameDataType -eq "Int64" -and $Values.FolderMethod -eq "Count" -and $Values.FolderValue -eq 0) {
                            $FolderSetting += ";Boolean::FolderExists"
                        }
                        else {
                            $FolderSetting += ";FilePropertyName::$($values.FolderPropertyName)"
                            $FolderSetting += ";FilePropertyDataType::$($Values.FolderPropertyNameDataType)"
                            $Operation = Convert-EdmOperator -Operator $Values.FolderOperator -Data "$($Values.FolderValue)" -DataList $($Values.FolderValueList)
                            $FolderSetting += ";Operator::" + $Operation
                        }
                        If ($Values.Folder64Bit -eq "false") {
                            $FolderSetting += ";3264::FolderAssociatedWith32-bitAppOn64-BitSystem" ##Checked
                        }

                        $FolderSetting
                    }
                    'MsiSetting' {
                        $MsiSetting = "ProductCode::$($values.MSIProductCode)"
                        If ($Values.MSIDataType -eq "Int64" -and $Values.MSIMethod -eq "Count" -and $Values.MSIDataValue -eq 0) {
                            $MsiSetting += ";MSIexists."
                        }
                        else {
                            $MsiSetting += ";MSIPropertyName::$($values.MSIPropertyName)"
                            $MsiSetting += ";MSIPropertyDataType::$($Values.MSIDataType)"
                            $Operation = Convert-EdmOperator -Operator $Values.MSIOperator -Data "$($Values.MSIDataValue)"
                            $MsiSetting += ";Operator::" + $Operation
                        }
                        $MsiSetting
                    }
                    Default {
                        $SettingDetails = 'UnknownDetectionSetting.'
                    }
                }
            }
        }
    }
}
