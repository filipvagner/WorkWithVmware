###########################################################
# AUTHOR  : Filip Vagner
# EMAIL   : filip.vagner@hotmail.com
# DATE    : 13-03-2019
# COMMENT : This  Powershell script gets informaiton about last time when virtual machine was running.
#
###########################################################
function Get-CmVMLastUseDEV {
    [CmdletBinding()]
    param (
        [string[]]$Name
    )
    begin {
        $vCenterServer = Read-Host "Name of vCenter to connect" # Insert name of vcenter
        Write-Host "Connecting to vCenter: " -NoNewline; Write-Host $vCenterServer -ForegroundColor Green
        Connect-VIServer -Server $vCenterServer -Credential (Get-Credential -Message 'Domain account' -UserName 'domain\username')
    }
    
    process {
        $VMList = @()
        foreach ($VMNameToSearch in $Name) {
            $VMDatacenter = Get-VM -Name $VMNameToSearch | Get-Datacenter | Select-Object -ExpandProperty Name
            $VMDatastore = Get-VM -Name $VMNameToSearch | Get-Datastore | Select-Object -ExpandProperty Name
            $VMName = (Get-VM -Name $VMNameToSearch).Name
            $PowerState = (Get-VM -Name $VMNameToSearch).PowerState
            $LastUse = (Get-ChildItem vmstore:\$VMDatacenter\$VMDatastore\$VMNameToSearch\vmware.log).LastWriteTime

            $VMValues = New-Object -TypeName PSObject
            $VMValues | Add-Member -MemberType NoteProperty -Name VMName -Value $VMName
            $VMValues | Add-Member -MemberType NoteProperty -Name PowerState -Value $PowerState
            $VMValues | Add-Member -MemberType NoteProperty -Name LastUse -Value $LastUse

            $VMList += $VMValues
            }
    }
    
    end {
        $VMList | Format-Table
        Disconnect-VIServer -Server $vCenterServer -Confirm:$false
    }
}
