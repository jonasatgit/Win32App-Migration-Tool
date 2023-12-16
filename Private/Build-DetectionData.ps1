function Build-DetectionData {
    
    $Detection = $Null

    Write-Host $defaultappsdt.DetectionMethod
    Switch ($defaultappsdt.DetectionMethod) {
        "Enhanced Detection Method" {
            #Get Detection Data
            ForEach ($Detection in $DetectionMethodArray) {
                If ($Detection -like "Registry*") {
                    $Detect = "Registry"
                    Write-Host $Detection
                    write-host "Detection Technology = Script Registry"
                }
                Elseif ($Detection -like "Product*") {
                    $Detect = "MSI"
                    Write-Host $Detection
                    write-host "Detection Technology = Script MSI"
                }
                Elseif ($Detection -like "FileSystemFile*") {
                    $Detect = "FileSystemFile"
                    Write-Host $Detection
                    write-host "Detection Technology = Script FileSystemFile"
                }
                Elseif ($Detection -like "FileSystemFolder*") {
                    $Detect = "FileSystemFolder"
                    Write-Host $Detection
                    write-host "Detection Technology = Script FileSystemFolder"
                }
                Else {
                    Write-Log -Message "Detection Data undefined" -LogId $LogId
                    Write-Host "Detection Data undefined" -ForegroundColor Red
                    Exit 5
                }
                Switch ($Detect) {
                    "Registry" {
                        Write-Host "Building Registry Detection"
              
                        $ValueDataType = ($Detection).split(';')[2]
                        Switch (($ValueDataType -split '::')[1]) {
                            "Exists" {
                                Write-Host "Using 'Reg key/value exists' Operator"
                                Write-Host $Detection
                                write-host "Detection Technology = Exists
                                "
                                $KeyPath = (($Detection -split ';')[0]).split('::')[2]
                                $ValueName = ((($Detection -split ';')[1]) -split ('::'))[1]
                                $check32BitOn64System = If ($Detection -like '*32-bitAppOn64-BitSystem') { $true } else { $false }
                                $DetectionType = (($($Detection).split(';')[2]) -split ('::'))[1]
                                
                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptRegistry"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "Existence"
                                $DTData | Add-Member NoteProperty -Name KeyPath -Value $KeyPath
                                $DTData | Add-Member NoteProperty -Name ValueName -Value $ValueName 
                                $DTData | Add-Member NoteProperty -Name check32BitOn64System -Value "`$$($Check32BitOn64System)"
                                $DTData | Add-Member NoteProperty -Name DetectionType -Value $DetectionType

                                Return $DTData
                            }
                            "String" {
                                Write-Host "Using 'String' Operator"
                                Write-Host $Detection
                                write-host "Detection Technology = String
                                "
                                $KeyPath = (($Detection -split ';')[0]).split('::')[2]
                                $ValueName = ((($Detection -split ';')[1]) -split ('::'))[1]
                                $check32BitOn64System = If ($Detection -like '*32-bitAppOn64-BitSystem') { $true } else { $false }
                                $StringComparisonOperator = (($($Detection).split(';')[3]).split('::'))[0]
                                $StringComparisonValue = ((($Detection).split(';')[3]).split('::'))[1]

                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptRegistry"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "StringComparison"
                                $DTData | Add-Member NoteProperty -Name KeyPath -Value $KeyPath
                                $DTData | Add-Member NoteProperty -Name ValueName -Value $ValueName 
                                $DTData | Add-Member NoteProperty -Name check32BitOn64System -Value "`$$($Check32BitOn64System)"
                                $DTData | Add-Member NoteProperty -Name StringComparisonOperator -Value $StringComparisonOperator
                                $DTData | Add-Member NoteProperty -Name StringComparisonValue -Value $StringComparisonValue

                                Return $DTData

                            }
                            "Version" {
                                Write-Host "Using 'Version' Operator"
                                Write-Host $Detection
                                write-host "Detection Technology = Version
                                "
                                $KeyPath = (($Detection -split ';')[0]).split('::')[2]
                                $ValueName = ((($Detection -split ';')[1]) -split ('::'))[1]
                                $check32BitOn64System = If ($Detection -like '*32-bitAppOn64-BitSystem') { $true } else { $false }
                                $VersionComparisonOperator = (($($Detection).split(';')[3]).split('::'))[0]
                                $VersionComparisonValue = (($($Detection).split(';')[3]).split('::'))[1]

                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptRegistry"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "VersionComparison"
                                $DTData | Add-Member NoteProperty -Name KeyPath -Value $KeyPath
                                $DTData | Add-Member NoteProperty -Name ValueName -Value $ValueName 
                                $DTData | Add-Member NoteProperty -Name check32BitOn64System -Value "`$$($Check32BitOn64System)"
                                $DTData | Add-Member NoteProperty -Name VersionComparisonOperator -Value $VersionComparisonOperator
                                $DTData | Add-Member NoteProperty -Name VersionComparisonValue -Value $VersionComparisonValue
                                Write-Host $DTData
                                Return $DTData
                            }
                            "Int64" {
                                Write-Host "Using 'Integer' Operator"
                                Write-Host $Detection
                                write-host "Detection Technology = Integer
                                "
                                $KeyPath = (($Detection -split ';')[0]).split('::')[2]
                                $ValueName = ((($Detection -split ';')[1]) -split ('::'))[1]
                                $check32BitOn64System = If ($Detection -like '*32-bitAppOn64-BitSystem') { $true } else { $false }
                                $IntegerComparisonOperator = (($($Detection).split(';')[3]).split('::'))[0]
                                $IntegerComparisonValue = (($($Detection).split(';')[3]).split('::'))[1]

                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptRegistry"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "IntegerComparison"
                                $DTData | Add-Member NoteProperty -Name KeyPath -Value $KeyPath
                                $DTData | Add-Member NoteProperty -Name ValueName -Value $ValueName 
                                $DTData | Add-Member NoteProperty -Name check32BitOn64System -Value "`$$($Check32BitOn64System)"
                                $DTData | Add-Member NoteProperty -Name IntegerComparisonOperator -Value $IntegerComparisonOperator
                                $DTData | Add-Member NoteProperty -Name IntegerComparisonValue -Value $IntegerComparisonValue

                                Return $DTData
                            }
                        }
                    }
                    "MSI" {
                        Write-Host "Building Script MSI Detection"
                        Write-Host "Using Script MSI"
                        $productCode = Get-TextWithin $defaultappsdt.UninstallCommandLine -StartChar '{' -EndChar '}'
                        Write-host "ProductCode $($productCode)"
                        $ProductVersionOperator = If ($defaultappsdt.DetectionData0 -Like "*MSIexists.") { 
                                "notConfigured"
                            }
                            Else {
                            ## Need to find an MSI that specifies another operator other than Exists
                                ((($defaultappsdt.DetectionData0).split(';')[3]) -split('::'))[1]
                            }
                            $ProductVersion = If ($defaultapps.Version -eq "") {
                                '1.0'
                            }
                            Else {
                                $defaultapps.Version
                            }

                        $DTData = [PSCustomObject]@{}
                        $DTData | Add-Member NoteProperty -Name Type -Value "ScriptMSI"
                        $DTData | Add-Member NoteProperty -Name ProductCode -Value $productCode
                        $DTData | Add-Member NoteProperty -Name ProductVersionOperator -Value $ProductVersionOperator
                        $DTData | Add-Member NoteProperty -Name ProductVersion -Value $ProductVersion
                        Write-Host $DTData
                        Return $DTData
                    }
                    "FileSystemFile" {
                        Write-Host "Building FileSystemFile Detection"
                        $Base =(($defaultappsdt.DetectionData0).split(';')[1]) -split ('::')
                        $Base = $Base[1]
                        Switch ($Base) {
                            ## Need something here for file Not Exist
                            "FileExists" {
                                Write-Host "Define that the detection rule will be existence based, e.g. if a file or folder exists or does not exist."
                                    
                                $Pathetic = ($defaultappsdt.DetectionData0 -split (';'))[0]
                                $Pathey = ($Pathetic -split ('::'))[1]
                                $path = Split-Path $Pathey -Parent
                                $fileOrFolder = Split-Path $Pathey -leaf
                                $check32BitOn64System = If ($defaultappsdt.DetectionData0 -like '*32-bitAppOn64-BitSystem') {
                                    $true
                                }
                                Else {
                                    $false
                                }
                                #Need to add logic to support does not exist. May need to create a test app with this condition.
                                $detectionType = 'exists'

                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptFileSystemFile"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "Existence"
                                $DTData | Add-Member NoteProperty -Name Path -Value $Path
                                $DTData | Add-Member NoteProperty -Name FileOrFolder -Value $FileOrFolder
                                $DTData | Add-Member NoteProperty -Name DetectionType -Value $DetectionType
                                $DTData | Add-Member NoteProperty -Name Check32BitOn64System -Value "`$$($Check32BitOn64System)"

                                 Write-Host "Calling New-IntuneWin32AppDetectionRuleFile Function"
                                 Return $DTData 
                            }                            
                            "DateModified" {
                                Write-Host "Building DateModified Detection"
                                Write-Host "Define that the detection rule will be based on a file or folders date modified value."

                                #Define the string
                                $string = $defaultappsdt.DetectionData0
                                # Seperating dates IF there are more than one (notice the space after the ;)
                                $string = $string.replace("; ", "\")
                                # Split the string into an array of key-value pairs
                                $pairs = $string.Split(';')

                                # Create a new hash table
                                $hashTable = @{}
                                # Loop through each pair
                                foreach ($pair in $pairs) {
                                    # Split the pair into a key and a value
                                    $keyValue = $pair -Split ('::')

                                    # Add the key-value pair to the hash table
                                    $hashTable[$keyValue[0]] = $keyValue[1]
                                }
                                If ($hashTable.Operator -like '*OneOf*') {
                                    Write-host "Operator is using the 'OneOf' method which is not supported" -ForegroundColor Red
                                    Write-Host "Detected multiple Dates in Detection Method. Building 2 Detection Rules"
                                    # Extrapolate the 2 dates

                                    # Assume $defaultappsdt.DetectionData0 contains two dates separated by a '\'
                                    $dateString = ($hashtable.Data).split('\')
                                    $datestringcount = ($hashtable.Data).split('\').count
                                    Write-Host "There are $($datestringcount) dates in the Detection Method"
                                    Write-host "Using first date for this detection method"

                                    $DateValueString = $DateString[0]
                                    $DateValueString2 = $DateString[1]
                                    ##Need to put in the logic for dates 2-9
                                    $Operator = "equal"
                                }
                                Elseif ($hashTable.Operator -like '*between*') {
                                    Write-host "Operator is using the 'between' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }
                                Elseif ($hashTable.Operator -like '*noneof*') {
                                    Write-host "Operator is using the 'noneof' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }

                                Else {
                                    $operator = $hashTable.Operator
                                    $DateValueString = $hashTable.Data
                                }

                                $Path = Split-Path $hashTable.FileSystemFile -Leaf
                                $FileOrFolder = Split-Path $hashTable.FileSystemFile -Parent
                                $DetectionType = "modifiedDate"

                                If ($defaultappsdt.DetectionData0 -like '*32-bitAppOn64-BitSystem') {
                                    $Check32BitOn64System = $True
                                    Write-Host "Detection Rule Type FileSystemFile
                                    "
                                }
                                Else {
                                    $Check32BitOn64System = $False
                                    Write-Host "Detection Rule Type FileSystemFile
                                    "
                                }
                                
                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptFileSystemFile"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "DateModified"
                                $DTData | Add-Member NoteProperty -Name DateValueString -Value $DateValueString 
                                $DTData | Add-Member NoteProperty -Name Path -Value $Path
                                $DTData | Add-Member NoteProperty -Name FileOrFolder -Value $FileOrFolder
                                $DTData | Add-Member NoteProperty -Name Operator -Value $Operator
                                $DTData | Add-Member NoteProperty -Name DetectionType -Value $DetectionType
                                $DTData | Add-Member NoteProperty -Name Check32BitOn64System -Value "`$$($Check32BitOn64System)"
                                
                                Return $DTData
                            }
                            "DateCreated" {
                                Write-Host "Building File Detection"
                                Write-Host "Using Date Created"

                                Write-Host "Define that the detection rule will be based on when a file or folder was created."

                                $string = $defaultappsdt.DetectionData0
                                # Seperating dates IF there are more than one (notice the space after the ;)
                                $string = $string.replace("; ", "\")
                                # Split the string into an array of key-value pairs
                                $pairs = $string.Split(';')

                                # Create a new hash table
                                $hashTable = @{}
                                # Loop through each pair
                                foreach ($pair in $pairs) {
                                    # Split the pair into a key and a value
                                    $keyValue = $pair -Split ('::')

                                    # Add the key-value pair to the hash table
                                    $hashTable[$keyValue[0]] = $keyValue[1]
                                }
                            #ONEOF
                                If ($hashTable.Operator -like '*OneOf*') {
                                    Write-host "Operator is using the 'OneOf' method which is not supported" -ForegroundColor Red
                                    Write-Host "Detected multiple Dates in Detection Method. Building 2 Detection Rules"
                                    # Extrapolate the 2 dates

                                    # Assume $defaultappsdt.DetectionData0 contains two dates separated by a '\'
                                    $dateString = ($hashtable.Data).split('\')
                                    $datestringcount = ($hashtable.Data).split('\').count
                                    Write-Host "There are $($datestringcount) dates in the Detection Method"
                                    Write-host "Using first date for this detection method"
                                    ## Need to figure out how to handle the others.

                                    $DateValueString = $DateString[0]
                                    $DateValueString2 = $DateString[1]
                                    ##Need to put in the logic for dates 2-9
                                    $Operator = "equal"
                                }
                            #BETWEEN
                                Elseif ($hashTable.Operator -like '*between*') {
                                    Write-host "Operator is using the 'between' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }
                            #NONEOF
                                Elseif ($hashTable.Operator -like '*noneof*') {
                                    Write-host "Operator is using the 'noneof' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }
                            #Default
                                Else {
                                    Write-Host "Operator is using a supported method" -ForegroundColor DarkGreen
                                    $Operator = $hashTable.Operator
                                    $DateValueString = $hashTable.data                          
                                }

                                $Path = Split-Path $hashTable.FileSystemFile -Leaf
                                $FileOrFolder = Split-Path $hashTable.FileSystemFile -Parent
                                                                $DetectionType = "DateCreated"

                                If ($defaultappsdt.DetectionData0 -like '*32-bitAppOn64-BitSystem') {
                                    $Check32BitOn64System = $True
                                    Write-Host "Detection Rule Type FileSystemFile
                                    "
                                }
                                Else {
                                    $Check32BitOn64System = $False
                                    Write-Host "Detection Rule Type FileSystemFile
                                    "
                                }
                                
                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptFileSystemFile"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "DateCreated"
                                $DTData | Add-Member NoteProperty -Name DateValueString -Value $DateValueString 
                                $DTData | Add-Member NoteProperty -Name Path -Value $Path
                                $DTData | Add-Member NoteProperty -Name FileOrFolder -Value $FileOrFolder
                                $DTData | Add-Member NoteProperty -Name Operator -Value $Operator
                                $DTData | Add-Member NoteProperty -Name DetectionType -Value $DetectionType
                                $DTData | Add-Member NoteProperty -Name Check32BitOn64System -Value "`$$($Check32BitOn64System)"
                                
                                Return $DTData
                            }
                            "Version" {
                                Write-Host "Building File Detection"
                                Write-Host "Using Version Operator"

                                Write-Host "Define that the detection rule will be based on the file version number specified as value."

                                #Set the String
                                $string = $defaultappsdt.DetectionData0
                                # Seperating dates IF there are more than one (notice the space after the ;)
                                $string = $string.replace("; ", "\")
                                # Split the string into an array of key-value pairs
                                $pairs = $string.Split(';')

                                # Create a new hash table
                                $hashTable = @{}
                                # Loop through each pair
                                foreach ($pair in $pairs) {
                                    # Split the pair into a key and a value
                                    $keyValue = $pair -Split ('::')

                                    # Add the key-value pair to the hash table
                                    $hashTable[$keyValue[0]] = $keyValue[1]
                                }
                            #ONEOF
                                If ($hashTable.Operator -like '*OneOf*') {
                                    Write-host "Operator is using the 'OneOf' method which is not supported" -ForegroundColor Red
                                    Write-Host "Detected multiple Dates in Detection Method. Building 2 Detection Rules"
                                    # Extrapolate the 2 dates

                                    # Assume $defaultappsdt.DetectionData0 contains two dates separated by a '\'
                                    $dateString = ($hashtable.Data).split('\')
                                    $datestringcount = ($hashtable.Data).split('\').count
                                    Write-Host "There are $($datestringcount) dates in the Detection Method"
                                    Write-host "Using first date for this detection method"
                                    ## Need to figure out how to handle the others.

                                    $DateValueString = $DateString[0]
                                    $DateValueString2 = $DateString[1]
                                    ##Need to put in the logic for dates 2-9
                                    $Operator = "equal"
                                }
                            #BETWEEN
                                Elseif ($hashTable.Operator -like '*between*') {
                                    Write-host "Operator is using the 'between' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }
                            #NONEOF
                                Elseif ($hashTable.Operator -like '*noneof*') {
                                    #parse each of these to individual notequal methods
                                    Write-host "Operator is using the 'noneof' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }
                            #Default
                                Else {
                                    Write-Host "Operator is using a supported method" -ForegroundColor DarkGreen
                                    $Operator = $hashTable.Operator
                                    $VersionValue = $hashTable.data                          
                                }

                                $Path = Split-Path $hashTable.FileSystemFile -Leaf
                                $FileOrFolder = Split-Path $hashTable.FileSystemFile -Parent
                                $DetectionType = "Version"

                                If ($defaultappsdt.DetectionData0 -like '*32-bitAppOn64-BitSystem') {
                                    $Check32BitOn64System = $True
                                    Write-Host "Detection Rule Type FileSystemFile
                                    "
                                }
                                Else {
                                    $Check32BitOn64System = $False
                                    Write-Host "Detection Rule Type FileSystemFile
                                    "
                                }
                                
                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptFileSystemFile"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "Version"
                                $DTData | Add-Member NoteProperty -Name VersionValue -Value $VersionValue 
                                $DTData | Add-Member NoteProperty -Name Path -Value $Path
                                $DTData | Add-Member NoteProperty -Name FileOrFolder -Value $FileOrFolder
                                $DTData | Add-Member NoteProperty -Name Operator -Value $Operator
                                $DTData | Add-Member NoteProperty -Name DetectionType -Value $DetectionType
                                $DTData | Add-Member NoteProperty -Name Check32BitOn64System -Value "`$$($Check32BitOn64System)"
                                
                                Return $DTData
                            } 
                            "Size" {
                                Write-Host "Building File Detection"
                                Write-Host "Using Size Method"

                                #Set the String
                                $string = $defaultappsdt.DetectionData0
                                # Seperating dates IF there are more than one (notice the space after the ;)
                                $string = $string.replace("; ", "\")
                                # Split the string into an array of key-value pairs
                                $pairs = $string.Split(';')

                                # Create a new hash table
                                $hashTable = @{}
                                # Loop through each pair
                                foreach ($pair in $pairs) {
                                    # Split the pair into a key and a value
                                    $keyValue = $pair -Split ('::')

                                    # Add the key-value pair to the hash table
                                    $hashTable[$keyValue[0]] = $keyValue[1]
                                }
                            #ONEOF
                                If ($hashTable.Operator -like '*OneOf*') {
                                    Write-host "Operator is using the 'OneOf' method which is not supported" -ForegroundColor Red
                                    Write-Host "Detected multiple Dates in Detection Method. Building 2 Detection Rules"
                                    # Extrapolate the 2 dates

                                    # Assume $defaultappsdt.DetectionData0 contains two dates separated by a '\'
                                    $dateString = ($hashtable.Data).split('\')
                                    $datestringcount = ($hashtable.Data).split('\').count
                                    Write-Host "There are $($datestringcount) dates in the Detection Method"
                                    Write-host "Using first date for this detection method"
                                    ## Need to figure out how to handle the others.

                                    $DateValueString = $DateString[0]
                                    $DateValueString2 = $DateString[1]
                                    ##Need to put in the logic for dates 2-9
                                    $Operator = "equal"
                                }
                            #BETWEEN
                                Elseif ($hashTable.Operator -like '*between*') {
                                    Write-host "Operator is using the 'between' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }
                            #NONEOF
                                Elseif ($hashTable.Operator -like '*noneof*') {
                                    #parse each of these to individual notequal methods
                                    Write-host "Operator is using the 'noneof' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }
                            #Default
                                Else {
                                    Write-Host "Operator is using a supported method" -ForegroundColor DarkGreen
                                    $Operator = $hashTable.Operator
                                    $SizeInMBValue = $hashTable.data                          
                                }

                                $Path = Split-Path $hashTable.FileSystemFile -Leaf
                                $FileOrFolder = Split-Path $hashTable.FileSystemFile -Parent
                                $DetectionType = "Version"

                                If ($defaultappsdt.DetectionData0 -like '*32-bitAppOn64-BitSystem') {
                                    $Check32BitOn64System = $True
                                    Write-Host "Detection Rule Type FileSystemFile
                                    "
                                }
                                Else {
                                    $Check32BitOn64System = $False
                                    Write-Host "Detection Rule Type FileSystemFile
                                    "
                                }
                                
                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptFileSystemFile"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "Size"
                                $DTData | Add-Member NoteProperty -Name SizeInMBValue -Value $SizeInMBValue 
                                $DTData | Add-Member NoteProperty -Name Path -Value $Path
                                $DTData | Add-Member NoteProperty -Name FileOrFolder -Value $FileOrFolder
                                $DTData | Add-Member NoteProperty -Name Operator -Value $Operator
                                $DTData | Add-Member NoteProperty -Name DetectionType -Value $DetectionType
                                $DTData | Add-Member NoteProperty -Name Check32BitOn64System -Value "`$$($Check32BitOn64System)"
                                
                                Return $DTData
                            }
                        }
                    }
                    "FileSystemFolder" {
                        Write-Host "Building Folder Detection"
                        Write-Host "Using FileSystemFolder"
                        $Base =(($defaultappsdt.DetectionData0).split(';')[1]) -split ('::')
                        $Base = $Base[1]
                        Switch ($Base) {
                            "FolderExists" {
                            ## Need something here for folder Not Exist
                                Write-Host "Define that the detection rule will be existence based, e.g. if a file or folder exists or does not exist."
                                    
                                    $Pathetic = ($defaultappsdt.DetectionData0 -split (';'))[0]
                                    $Pathey = ($Pathetic -split ('::'))[1]
                                    $path = Split-Path $Pathey -Parent
                                    $fileOrFolder = Split-Path $Pathey -leaf
                                    $check32BitOn64System = If ($defaultappsdt.DetectionData0 -like '*32-bitAppOn64-BitSystem') {
                                        $true
                                    }
                                    Else {
                                        $false
                                    }
                                    #Need to add logic to support does not exist. May need to create a test app with this condition.
                                    $detectionType = 'exists'

                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptFileSystemFolder"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "Existence"
                                $DTData | Add-Member NoteProperty -Name Path -Value $Path
                                $DTData | Add-Member NoteProperty -Name FileOrFolder -Value $FileOrFolder
                                $DTData | Add-Member NoteProperty -Name DetectionType -Value $DetectionType
                                $DTData | Add-Member NoteProperty -Name Check32BitOn64System -Value "`$$($Check32BitOn64System)"

                                Write-Host "Calling New-IntuneWin32AppDetectionRuleFile Function"
                                Return $DTData 
                            }                            
                            "DateModified" {
                                Write-Host "Building DateModified Detection"
                                Write-Host "Define that the detection rule will be based on a file or folders date modified value."

                                #Define the string
                                $string = $defaultappsdt.DetectionData0
                                # Seperating dates IF there are more than one (notice the space after the ;)
                                $string = $string.replace("; ", "\")
                                # Split the string into an array of key-value pairs
                                $pairs = $string.Split(';')

                                # Create a new hash table
                                $hashTable = @{}
                                # Loop through each pair
                                foreach ($pair in $pairs) {
                                    # Split the pair into a key and a value
                                    $keyValue = $pair -Split ('::')

                                    # Add the key-value pair to the hash table
                                    $hashTable[$keyValue[0]] = $keyValue[1]
                                }
                                If ($hashTable.Operator -like '*OneOf*') {
                                    Write-host "Operator is using the 'OneOf' method which is not supported" -ForegroundColor Red
                                    Write-Host "Detected multiple Dates in Detection Method. Building 2 Detection Rules"
                                    # Extrapolate the 2 dates

                                    # Assume $defaultappsdt.DetectionData0 contains two dates separated by a '\'
                                    $dateString = ($hashtable.Data).split('\')
                                    $datestringcount = ($hashtable.Data).split('\').count
                                    Write-Host "There are $($datestringcount) dates in the Detection Method"
                                    Write-host "Using first date for this detection method"
                                    ## Need to figure out how to handle the others.

                                    $DateValueString = $DateString[0]
                                    $DateValueString2 = $DateString[1]
                                    ##Need to put in the logic for dates 2-9
                                    $Operator = "equal"
                                }
                                Elseif ($hashTable.Operator -like '*between*') {
                                    Write-host "Operator is using the 'between' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }
                                Elseif ($hashTable.Operator -like '*noneof*') {
                                    Write-host "Operator is using the 'noneof' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }
                                Else {
                                    Write-Host "Operator is using a supported method" -ForegroundColor DarkGreen
                                    $Operator = $hashTable.Operator
                                    $DateValueString = $hashTable.data                          
                                }

                                $Path = Split-Path $hashTable.FileSystemFolder -Leaf
                                $FileOrFolder = Split-Path $hashTable.FileSystemFolder -Parent
                                $DetectionType = "DateModified"

                                If ($defaultappsdt.DetectionData0 -like '*32-bitAppOn64-BitSystem') {
                                    $Check32BitOn64System = $True
                                    Write-Host "Detection Rule Type FileSystemFolder
                                    "
                                }
                                Else {
                                    $Check32BitOn64System = $False
                                    Write-Host "Detection Rule Type FileSystemFolder
                                    "
                                }
                                
                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptFileSystemFolder"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "DateModified"
                                $DTData | Add-Member NoteProperty -Name DateValueString -Value $DateValueString 
                                $DTData | Add-Member NoteProperty -Name Path -Value $Path
                                $DTData | Add-Member NoteProperty -Name FileOrFolder -Value $FileOrFolder
                                $DTData | Add-Member NoteProperty -Name Operator -Value $Operator
                                $DTData | Add-Member NoteProperty -Name DetectionType -Value $DetectionType
                                $DTData | Add-Member NoteProperty -Name Check32BitOn64System -Value "`$$($Check32BitOn64System)"
                                
                                Return $DTData
                            }
                            "DateCreated" {
                                Write-Host "Building Folder Detection"
                                Write-Host "Using Date Created"

                                Write-Host "Define that the detection rule will be based on when a file or folder was created."

                                $string = $defaultappsdt.DetectionData0
                                # Seperating dates IF there are more than one (notice the space after the ;)
                                $string = $string.replace("; ", "\")
                                # Split the string into an array of key-value pairs
                                $pairs = $string.Split(';')

                                # Create a new hash table
                                $hashTable = @{}
                                # Loop through each pair
                                foreach ($pair in $pairs) {
                                    # Split the pair into a key and a value
                                    $keyValue = $pair -Split ('::')

                                    # Add the key-value pair to the hash table
                                    $hashTable[$keyValue[0]] = $keyValue[1]
                                }
                                If ($hashTable.Operator -like '*OneOf*') {
                                    Write-host "Operator is using the 'OneOf' method which is not supported" -ForegroundColor Red
                                    Write-Host "Detected multiple Dates in Detection Method. Building 2 Detection Rules"
                                    # Extrapolate the 2 dates

                                    # Assume $defaultappsdt.DetectionData0 contains two dates separated by a '\'
                                    $dateString = ($hashtable.Data).split('\')
                                    $datestringcount = ($hashtable.Data).split('\').count
                                    Write-Host "There are $($datestringcount) dates in the Detection Method"
                                    Write-host "Using first date for this detection method"
                                    ## Need to figure out how to handle the others.

                                    $DateValueString = $DateString[0]
                                    $DateValueString2 = $DateString[1]
                                    ##Need to put in the logic for dates 2-9
                                    $Operator = "equal"
                                }
                                Elseif ($hashTable.Operator -like '*between*') {
                                    Write-host "Operator is using the 'between' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }
                                Elseif ($hashTable.Operator -like '*noneof*') {
                                    Write-host "Operator is using the 'noneof' method which is not supported" -ForegroundColor Red
                                    $DateValueString = $hashtable.something
                                    $Operator = ""
                                }
                                Else {
                                    Write-Host "Operator is using a supported method" -ForegroundColor DarkGreen
                                    $Operator = $hashTable.Operator
                                    $DateValueString = $hashTable.data                          
                                }

                                $Path = Split-Path $hashTable.FileSystemFolder -Leaf
                                $FileOrFolder = Split-Path $hashTable.FileSystemFolder -Parent
                                $DetectionType = "DateCreated"

                                If ($defaultappsdt.DetectionData0 -like '*32-bitAppOn64-BitSystem') {
                                    $Check32BitOn64System = $True
                                    Write-Host "Detection Rule Type FileSystemFolder
                                    "
                                }
                                Else {
                                    $Check32BitOn64System = $False
                                    Write-Host "Detection Rule Type FileSystemFolder
                                    "
                                }
                                
                                $DTData = [PSCustomObject]@{}
                                $DTData | Add-Member NoteProperty -Name Type -Value "ScriptFileSystemFolder"
                                $DTData | Add-Member NoteProperty -Name DetectionParam -Value "DateCreated"
                                $DTData | Add-Member NoteProperty -Name DateValueString -Value $DateValueString 
                                $DTData | Add-Member NoteProperty -Name Path -Value $Path
                                $DTData | Add-Member NoteProperty -Name FileOrFolder -Value $FileOrFolder
                                $DTData | Add-Member NoteProperty -Name Operator -Value $Operator
                                $DTData | Add-Member NoteProperty -Name DetectionType -Value $DetectionType
                                $DTData | Add-Member NoteProperty -Name Check32BitOn64System -Value "`$$($Check32BitOn64System)"
                                
                                Return $DTData
                            }
                        }
                    }
                }

            }

        }
        "MSI Detection Method" {
        #NEED to figure out a work around for uninstallcommandlines that dont have a product code (VMware Horizon Client 5.4.2)
        ## Root issue is MSI apps that were changed to USE an EXE, work around is having PMP handle these, not a long term solution
            Write-Host "Building MSI Detection"
            $productCode = Get-TextWithin $defaultappsdt.UninstallCommandLine -StartChar '{' -EndChar '}'
            Write-host "ProductCode $($productCode)"
            $ProductVersionOperator = If ($defaultappsdt.DetectionData0 -eq "MSI exists.") { "notConfigured" }
                Else { ($defaultappsdt.DetectionData0).split(':')[0] }
            $ProductVersion = If ($defaultapps.Version -eq "") { '1.0' }
                Else { $defaultapps.Version }

            $DTData = [PSCustomObject]@{}
            $DTData | Add-Member NoteProperty -Name Type -Value "MSI"
            $DTData | Add-Member NoteProperty -Name ProductCode -Value $productCode
            $DTData | Add-Member NoteProperty -Name ProductVersionOperator -Value $ProductVersionOperator
            $DTData | Add-Member NoteProperty -Name ProductVersion -Value $ProductVersion
            Write-Host $DTData

            Return $DTData

        }
        "Script Detection Method" {
            ForEach ($Detection in $DetectionMethodArray) {
                If ($Detection -like "Powershell*") {
                    $Detect = "Powershell"
                    Write-Host $Detection
                    write-host "Detection Technology = Powershell Script"
                    
                    $Type = "ScriptScript"
                    $ScriptFile = ($defaultappsdt.detectiondata0.split(';')[1])
                    $scriptFile = ($scriptFile -split ('::'))[1]
                    $EnforceSignatureCheck = $false
                    $RunAs32Bit = ($defaultappsdt.detectiondata0.split(';')[2])
                    $RunAs32Bit = "$"+($RunAs32Bit -split ('::'))[1]

                    $DTData = [PSCustomObject]@{}
                    $DTData | Add-Member NoteProperty -Name Type -Value $Type
                    $DTData | Add-Member NoteProperty -Name ScriptFile -Value $ScriptFile
                    $DTData | Add-Member NoteProperty -Name EnforceSignatureCheck -Value $EnforceSignatureCheck
                    $DTData | Add-Member NoteProperty -Name Check32BitOn64System -Value $RunAs32Bit
                    Write-Host $DTData

                    Return $DTData


                }
                Elseif ($Detection -like "VBScript*") {
                    $Detect = "VBScript"
                    Write-Host $Detection
                    write-host "Detection Technology = VBScript Script"
                }
                Elseif ($Detection -like "JScript*") {
                    $Detect = "JScript"
                    Write-Host $Detection
                    write-host "Detection Technology = JScript Script"
                }
                Else {
                    Write-Host This one $Detection
                    Write-Host "Detection Data undefined" -ForegroundColor Red
                    Exit 5
                }
    }



}
    }

    # Gather other details
    # Need to clean this up and move it somewhere else
    If ($defaultapps.Description -like "" -or $null -eq $defaultapps.Description) {
        $Description = "default"
    }
    else {
        $Description = $defaultapps.Description
    }
    If ($defaultapps.Publisher -like "") {
        $Publisher = "default"
    }
    else {
        $Publisher = $defaultapps.Publisher
    }
}
