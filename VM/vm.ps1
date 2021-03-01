
function CreateVM
{
    param ([string]$VMName, [string]$VMRootFolder, $VHDSize, [int]$VMGen, [string]$ISOPath, [int]$CpuCount)

    # assume there is already an external switch and use the first external switch we find
    $switches = Get-VMSwitch
    foreach($i in $switches)
    {
        if ($i.SwitchType -ceq "External")
        {
            $ExternalSwitchName = $i.Name
        }
    }

    Write-Host($ExternalSwitchName)

    New-VM -Name $VMName -MemoryStartupBytes 4GB -BootDevice VHD -NewVHDPath $VMRootFolder'\'$VMName'\'$VMName'.vhdx' -Path $VMRootFolder'\'$VMName -NewVHDSizeBytes $VHDSize -Generation $VMGen -Switch $ExternalSwitchName
    Add-VMDvdDrive -VMName $VMName -Path $ISOPath
    $dvd = Get-VMDvdDrive -VMName $VMName
    Set-VMFirmware $VMName -FirstBootDevice $dvd
    Set-VMProcessor $VMName -Count $CpuCount
    Start-VM $VMName
}

function ImportVM
{
    param([string]$NewVMPath, [string]$OldVMPath)

    $switches = Get-VMSwitch
    foreach($i in $switches)
    {
        if ($i.SwitchType -ceq "External")
        {
            $ExternalSwitchName = $i.Name
        }
    }

    $vmcx = Get-ChildItem $OldVMPath"\*.vmcx" -Recurse

    Write-Host($vmcx)

    $newVM = Import-VM -Path $vmcx.FullName -VhdDestinationPath $NewVMPath -Copy -GenerateNewId -VirtualMachinePath $NewVMPath
    
    Add-VMNetworkAdapter -VMName $newVM.Name -SwitchName $ExternalSwitchName

    $importedName = $newVM.Name
    $changedName = $importedName + $(Get-Date)

    Rename-VM $importedName $changedName

    Start-VM $changedName
}

# usage
# CreateVM -VMName test3 -VMRootFolder d:\hyperv -VHDSize 100GB -VMGen 1 -ISOPath D:\ISO\ubuntu-20.04.2-live-server-amd64.iso -CpuCount 4