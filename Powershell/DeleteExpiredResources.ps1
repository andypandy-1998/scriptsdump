
#useful tags to keep in mind during the script:
#
#
#
#
#
#Conenction
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
#
#
#CHANGE THESE VARIABLES
$v_tagname = "ExpirationDate"  #Expiration Date tag name, in this case, ExpirationDate
$v_tagname2 = "Owner" #owner tag name, in this case, Owner
$v_organizationName = "TestOrganization" #If there's a name for the organization and such a tag. Necessary for this code.
$v_subscriptionID = $servicePrincipalConnection.SubscriptionID
#
#
#Code checks whether there's any resources tagged with the ORGANIZATION NAME and then finds does a bunch of comparisons in order to deduce
#whether or not to delete it. 
#
#CODE REVIEW BELOW
#get the resources with the Tag Expiration Date
$allRes = (Get-AzResource -TagName $v_tagname).Name
For ($i = 0; $i -lt $allRes.Count; $i++) {
    $tags = (Get-AzResource -ResourceName $allRes[$i]).Tags
    if ($tags.$v_tagname2 -like $v_organizationName) {
        #debug output
        Write-Output $allRes[$i]  " from $v_organizationName = True" 
        #get today's date duh
        $todayDate = Get-Date
        #parse the date on the string and reformat it 
        #compare today's date with a function that parses the fetched tag date
        if ($todayDate -gt [datetime]::ParseExact($tags.$v_tagname, "M/dd/yyyy", $null)) {
            Write-Output "Is More, Deleting..."
            #DELETE FUNCTION
            # find ResourceID of Resource and then delete it
            #set context
            $context = Set-AzContext -SubscriptionID $v_subscriptionID
            
            #for to find the ResourceID and Resource Group
            $getAllResources = Get-AzResource
            for ($ii = 0; $ii -lt $getAllResources.Count; $ii++) {
                if ($getAllResources[$ii].Name -like $allRes[$i]) {
                        $v_resourceID = $getAllResources[$ii].ResourceID

                    
                    
                }
            }
            
            Remove-AzResource -ResourceID $v_resourceID -DefaultProfile $context -Force
            
        }
        else {
            Write-Output "Is Less, nothing done"
            #nothing done because there's nothing to do :)
        }

    } 

}

