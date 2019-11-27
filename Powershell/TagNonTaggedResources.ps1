Write-Output "Starting to find all non-tagged resources"
#fetch all resources~
#
#
#Connection 
$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
Add-AzAccount `
-ServicePrincipal `
-TenantId $servicePrincipalConnection.TenantId `
-ApplicationId $servicePrincipalConnection.ApplicationId `
-CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null

Set-AzContext -SubscriptionID $servicePrincipalConnection.SubscriptionID | Out-Null
#End Connection
#
#
#webhook, change accordingly TEAMS MESSAGING
$v_incomingWebhook = "<your webhook>"
$v_timeset = "ONE MONTH (31 days)" #follow this template: ONE MONTH (31 days), ONE YEAR (365 days), ONE FORTNIGHT (15 days), etc.
$text = "["
$number = 0;


$allresources = Get-AzResource 
foreach ($item in $allresources) {
    if (($item.Tags).Count -eq 0) {
        Write-Output "Found $item.Name without a tag. Tagging."
        #tag all items with a month's time to delete
        #include an automated message to teams       
        #find date of today to install the new deadline
        #
        #
        $today = Get-Date
        $ts = New-Timespan -Days 31 
        #
        #since we assume its empty, we first need to add a tag manually so we can add to it later on
        #
        Set-AzResource -ResourceId $item.Id -Tag @{ 'ExpirationDate' = ($today + $ts).ToString('MM/dd/yyyy') } -Force
        $Tags = (Get-AzResource -ResourceId $item.Id).Tags 
        $Tags.Add('IsNotTagged', 'True')
        #
        #here's how it's added later on
        #
        Set-AzResource -ResourceId $item.Id -Tag $Tags -Force
        
         
        #Write-Output 'New Expiration Date: '+  $today.ToString('MM/dd/yyyy')
        #Set-AzResource -ResourceId $item.id -Tag $Tag -Force 
        #debug output ignore pls
        #
        #
        #Concatonate string
        #
        #
        #
        $string = $item.Name + ",`n"
        $text += $string
        #iterate through a number and then compare it to the count downbelow
        $number++;
    }
    else {
        #else nothing hap hap hap hap XD this means this resource does have tags and will be ignored.
        #TODO check whether the correct tags are in place
        #i've had it
    }

    
    
}
#and then i saw her number
#and I'm a believer
#checks if there's at least one tag and then sends the json
#
if ($number -gt 0) {
    $CANCEL = 0
}
else {
    $CANCEL = 1
}

if ($CANCEL -eq 0) {

    $text += "]"
    $payload = @{
        "title" = "ALERT: The following Resources were found to NOT be tagged and were therefore tagged with the appropriate IsNotTagged and ExpirationDates tag. The date is set for $v_timeset from now."
        "text"  = $text 
    } 

    $json = ConvertTo-Json $payload
    #1
    #2
    #3
    #DEPLOY
    #Exception
    Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $json -Uri $v_incomingWebhook
}
else { Write-Output "Because there were no tags to be added, no message has been sent." }
