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
$managedDisks = Get-AzResource -ResourceType 'Microsoft.Compute/disks' | Where-Object { $_.AttachedTo -like $null }
foreach($item in $managedDisks) {
    Write-Output "Deleting disk " $item.Name
    $item | Remove-AzResource -Force
    Write-Output "Deleted disk " $item.Name
}
