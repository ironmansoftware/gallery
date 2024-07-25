class TestConnection {
    [string]$ComputerName
    [bool]$TraceRoute
}

$Variables["Model"] = [TestConnection]::new()
$Variables["Output"] = ""
$Variables["Testing"] = $false

$Variables["LabelCol"] = [AntDesign.ColLayoutParam]::new()
$Variables["LabelCol"].Span = 6

$Variables["WrapperCol"] = [AntDesign.ColLayoutParam]::new()
$Variables["WrapperCol"].Span = 18

function Submit {
    param($EventArgs)

    $TraceRoute = $EventArgs.Model.TraceRoute

    Write-Host $TraceRoute

    $Variables["Testing"] = $true
    $Variables["Output"] = Test-NetConnection -ComputerName $EventArgs.Model.ComputerName -TraceRoute:$TraceRoute | Out-String 
    $Variables["Testing"] = $false
}