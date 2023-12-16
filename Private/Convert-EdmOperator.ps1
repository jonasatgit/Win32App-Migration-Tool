Function Convert-EdmOperator {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Operator,
        [Parameter(Mandatory = $false)]
        [string]
        $Data,
        [Parameter(Mandatory = $false)]
        [string[]]
        $DataList
    )
    switch ($Operator) {
        Equals { $OperationText = "Equal;Data::$Data" }
        NotEquals { $OperationText = "notEqual;Data::$Data" }
        GreaterEquals { $OperationText = "greaterThanOrEqual;Data::$Data" }
        LessThan { $OperationText = "lessthan;Data::$Data" }
        LessEquals { $OperationText = "lessThanorEqual;Data::$Data" }
        GreaterThan { $OperationText = "greaterThan;Data::$Data" }
        Between { $OperationText = "between;Data::$($DataList[0])-$($DataList[1])" }
        OneOf { $OperationText = "OneOf;Data::$($DataList -join '; ')" }
        NoneOf { $OperationText = "NoneOf;Data::$($DataList -join '; ')" }
        BeginsWith { $OperationText = "beginsWith;Data::$Data" }
        NotBeginsWith { $OperationText = "notbeginWith;Data::$Data" }
        EndsWith { $OperationText = "Endswith;Data::$Data" }
        NotEndsWith { $OperationText = "notendwith;Data::$Data" }
        Contains { $OperationText = "Contain;Data::$Data" }
        NotContains { $OperationText = "notcontain;Data::$Data" }
        default { $OperationText = "UnknownOperationForData." }
    }
    Write-Output $OperationText
}
