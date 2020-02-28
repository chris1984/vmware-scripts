<#
.SYNOPSIS
    Create a folder on a datastore
.DESCRIPTION
    Script used to test folder creation on a datastore with a user account. This will test permissions as well as provide debug output
    for foreman_bootdisk debugging
    Replace Line# 19 with your vCenter URL and username/password you are going to authenticate with
    Replace Line# 21 Datastore1 with the datastore you are wanting to test against
.NOTES
    File Name      : folder-create.ps1
    Author         : Chris Roberts chrobert@redhat.com
    Prerequisite   : PowerShell V2
.LINK
    Script posted at:
    http://github.com/chris1984/vmware-scripts   
#>

# Connect to the VMware vCenter
Connect-VIServer -Server <vcenterfqdn> -User <adminuser> -Password <adminpassword>

# Store datastore as variable so we can use it for folder creation
$DataStore = Get-Datastore -Name Datastore1

# Set datastore as a PowerShell drive so we do not have to mess with Linux/Windows local file creation
New-PSDrive -Location $datastore -Name DS -PSProvider VimDatastore -Root "\"

# Create the directory on the datastore
New-Item -Path DS:\powershell_directory -ItemType Directory

# Let user know directory was created
Write-Host "Directory powershell_directory has been created on datastore $DataStore"

# Remove PowerShell drive
Remove-PSDrive -Name DS -Confirm:$false

# Let user know script is finished
Write-Host "Script finished, please verify in vCenter that the directory is present"

# Disconnect from vCenter server
Disconnect-VIServer -Confirm:$false