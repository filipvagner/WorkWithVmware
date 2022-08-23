###########################################################
# AUTHOR  : Filip Vagner
# EMAIL   : filip.vagner@hotmail.com
# DATE    : 26-10-2018
# COMMENT : This  Powershell script gets informaiton about datastore.
#           - Display hosts connected to datastore
#           - Display virtual machines running on datastore (Name, OS version)
#
# FIX: Modify into function
###########################################################

# Connect to vCenter
$vCenterServer = Read-Host "Name of vCenter to connect" # Insert name of vcenter
Write-Host "Connecting to vCenter: " -NoNewline; Write-Host $vCenterServer -ForegroundColor Green
Connect-VIServer -Server $vCenterServer -Credential (Get-Credential -Message 'Domain account' -UserName 'domain\username')

# Getting name of datastore
$DatastoreToCheck = Read-Host "Datastore to check"

# Geting all hosts connected to datastore
$HostsConnectedToDS = Get-Datastore -Name $DatastoreToCheck | Get-VMHost

# Getting info about datastore
Write-Host "`nDatastore information:"
Get-Datastore -Name $DatastoreToCheck | Select-Object Name, @{Name = 'UsedPercents' ; Expression = {[math]::Round((((($_.CapacityGB)-($_.FreespaceGB))*100)/$_.CapacityGB),2)}}, @{Name = "FreeSpaceGB" ; Expression = {$_.FreeSpaceGB -as [int]}}, @{Name = "CapacityGB" ; Expression = {$_.CapacityGB -as [int]}}

# Getting info to what cluster is each host connected
Write-Host "`nHosts connected to datastore:"
foreach ($HostInfo in $HostsConnectedToDS)
{
    $HostName = $HostInfo.Name
    $HostInCluster = $HostInfo.Parent
    Write-Host "Host $HostName is in cluster $HostInCluster"
}

# Getting list of virtual machines running on datastore
Write-Host "`nVirtual machines running on datastore:"
Get-Datastore -Name $DatastoreToCheck | Get-VM | Select-Object Name, PowerState, Guest | Format-Table -AutoSize

# Disconnecting from current vCenter
Disconnect-VIServer -Server $vCenterServer -Confirm:$false
