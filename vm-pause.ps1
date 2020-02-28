<#
.SYNOPSIS
    Loop through all the powered on VMs in the vCenter server and pauses them.
.DESCRIPTION
    Used if you need to quickly do maintence on the hosts or the datastores and don't want to cause any issues with dataloss
.NOTES
    File Name      : vm-pause.ps1
    Author         : Chris Roberts chrobert@redhat.com
    Prerequisite   : PowerShell V2
.LINK
    Script posted at:
    http://github.com/chris1984/vmware-scripts   
#>

# Connect to the VMware vCenter
Connect-VIServer -Server <vcenterfqdn> -User <adminuser> -Password <adminpassword>

# Get list of vm names that are going to be shut off
Get-VM |Where-object {$_.powerstate -eq "poweredon"} | Format-Table -AutoSize -Wrap

# Store that to a variable
$VMs = Get-VM |Where-object {$_.powerstate -eq "poweredon"}

# Put VMs into suspend mode
$VMs | Suspend-VM -Confirm:$false

# Disconnect from vCenter server
Disconnect-VIServer -Confirm:$false