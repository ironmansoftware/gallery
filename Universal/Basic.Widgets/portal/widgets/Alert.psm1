function Initialize-PSUWidget {
    param(
        $Text = "Alert",
        $Type = "Success"
    )

    $Variables["Text"] = $Text 
    $Variables["Type"] = $Type.ToLower()
}