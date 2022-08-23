<#
    .Synopsis
        This cmdlet retrieves information about account in VMware vCenter
    .Description
        Cmdlet accpets only one account at the time.
        Cmdlet accept array of vCenters to check.
        "Cm" in cmdlet stands for "CustomModule".
    .Example
        Get-CmVcenterUser -AccountToCheck 'VSPHERE.LOCAL\administrator' -vCenterList (Get-Content -Path "$env:USERPROFILE\Documents\vm-find\vcenter-list.txt")
    .Example
        Get-CmVcenterUser -AccountToCheck 'VSPHERE.LOCAL\administrator' -vCenterList 'vcenter.local'
    .Notes
        AUTHOR  : Filip Vagner
        EMAIL   : filip.vagner@hotmail.com
        CREATED : 04-02-2020
    .Link
        https://github.com/filipvagner
#>
function Get-CmVcenterUser {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateCount(1, 1)]
        [string[]]$AccountToCheck,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNull()]
        [string[]]$vCenterList
    )
    
    begin {
        $ErrorActionPreference = 'SilentlyContinue'
        $ConfirmPreference = 'None'
        $vCenterCredentials = (Get-Credential -Message "Enter credentials to log in to vCenter")
        $accountToCheckInfoList = @()
    }
    
    process {
        foreach ($vCenterServer in $vCenterList) {
            Write-Host "Connecting to vCenter: " -NoNewline; Write-Host $vCenterServer -ForegroundColor Green
            
            try {
                Connect-VIServer -Server $vCenterServer -Credential $vCenterCredentials -ErrorAction Stop
            }
            catch {
                Write-Warning "Could not connect to '$vCenterServer'"
            }
            
            if (!(Get-VIPermission -Principal $AccountToCheck -ErrorAction SilentlyContinue)) {
                $accountToCheckInfo = [PSCustomObject]@{
                    AccountName = $null
                    Role = $null
                    vCenter = $vCenterServer
                }
                $accountToCheckInfoList = $accountToCheckInfoList + $accountToCheckInfo
            } else {
                $AccountToCheckCurrent = Get-VIPermission -Principal $AccountToCheck
                $accountToCheckInfo = [PSCustomObject]@{
                    AccountName = $AccountToCheckCurrent.Principal
                    Role = $AccountToCheckCurrent.Role
                    vCenter = $vCenterServer
                }
                $accountToCheckInfoList = $accountToCheckInfoList + $accountToCheckInfo    
            }
            Clear-Variable -Name AccountToCheckCurrent
            Disconnect-VIServer -Server $vCenterServer -Confirm:$false
        }        
    }
    
    end {
        $accountToCheckInfoList
    }
}
