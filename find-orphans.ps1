<#
.SYNOPSIS
    Find orphaned vmdk's in your vCenter environment
.DESCRIPTION
    Script used find orphaned vmdk's in your vCenter environment
    Replace Line# 18 with your vCenter URL and username/password you are going to authenticate with
.NOTES
    File Name      : find-orphans.ps1
    Author         : Chris Roberts chrobert@redhat.com and https://www.altaro.com/vmware/find-orphaned-vsphere-vms-using-powercli/
    Prerequisite   : PowerShell V2
.LINK
    Script posted at:
    http://github.com/chris1984/vmware-scripts   
#>

# Connect to the VMware vCenter
Connect-VIServer -Server <vcenterfqdn> -User <adminuser> -Password <adminpassword>

$arrUsedDisks = Get-VM | Get-HardDisk | %{$_.filename}
 $arrUsedDisks += get-template | Get-HardDisk | %{$_.filename}
 $arrDS = Get-Datastore
 Foreach ($strDatastore in $arrDS)
 {
 $strDatastoreName = $strDatastore.name
 $ds = Get-Datastore -Name $strDatastoreName | %{Get-View $_.Id}
 $fileQueryFlags = New-Object VMware.Vim.FileQueryFlags
 $fileQueryFlags.FileSize = $true
 $fileQueryFlags.FileType = $true
 $fileQueryFlags.Modification = $true
 $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
 $searchSpec.details = $fileQueryFlags
 $searchSpec.sortFoldersFirst = $true
 $dsBrowser = Get-View $ds.browser
 $rootPath = "["+$ds.summary.Name+"]"
 $searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)
 $myCol = @()
 foreach ($folder in $searchResult)
 {
 foreach ($fileResult in $folder.File)
 {
 $file = "" | select Name, FullPath 
 $file.Name = $fileResult.Path
 $strFilename = $file.Name
 IF ($strFilename)
 {
 IF ($strFilename.Contains(".vmdk")) 
 {
 IF (!$strFilename.Contains("-flat.vmdk"))
 {
 IF (!$strFilename.Contains("delta.vmdk")) 
 {
 $strCheckfile = "*"+$file.Name+"*"
 IF ($arrUsedDisks -Like $strCheckfile){}
 ELSE 
 { 
 $strOutput = $strDatastoreName + " Orphaned VMDK Found: " + $strFilename
 $strOutput
 } 
 }
 } 
 }
 }
 }
 } 
 }
