
class ObjectSearch {
    [string]$SearchString
}

$Variables["Model"] = [ObjectSearch]::new()
$Variables["Result"] = @()

function Initialize-PSUWidget {
    param([string]$ObjectClass, [string]$SearchBase)

    $Variables["ObjectClass"] = $ObjectClass
    $Variables["SearchBase"] = $SearchBase
}

function Find-PSUADObject {
    param($EventArgs)

    $parameters = @{
        Filter      = "Name -like '*$($EventArgs.Model.SearchString)*'"
        SearchScope = "Subtree"
        Properties  = "*"
    }

    if ($EventArgs.Model.SearchBase) {
        $parameters["SearchBase"] = $EventArgs.Model.SearchBase
    }

    $Variables["Result"] = Get-ADObject @parameters | Select-Object Name, DistinguishedName, ObjectClass
}