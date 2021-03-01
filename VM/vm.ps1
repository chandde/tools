
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
            break
        }
    }

    if ($ExternalSwitchName -eq $null)
    {
        Write-Error "Cannot find any external virtual switch" -ErrorAction Stop
    }

    $vm = New-VM -Name $VMName -MemoryStartupBytes 4GB -BootDevice VHD -NewVHDPath $VMRootFolder'\'$VMName'\'$VMName'.vhdx' -Path $VMRootFolder'\'$VMName -NewVHDSizeBytes $VHDSize -Generation $VMGen -Switch $ExternalSwitchName
    
    if ($vm -eq $null)
    {
        Write-Error "Fail to create VM" -ErrorAction Stop
    }

    Set-VMDvdDrive -VMName $VMName -Path $ISOPath

    if ($VMGen -eq 2)
    {
        $dvd = Get-VMDvdDrive -VMName $VMName
    
        Set-VMFirmware $VMName -FirstBootDevice $dvd
    }

    if ($VMGen -eq 1)
    {
        Set-VMBios $VMName -StartupOrder @("CD", "IDE", "LegacyNetworkAdapter", "Floppy")
    }
    
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
            break
        }
    }

    if ($ExternalSwitchName -eq $null)
    {
        Write-Error "Cannot find any external virtual switch" -ErrorAction Stop
    }

    $vmcx = Get-ChildItem $OldVMPath"\*.vmcx" -Recurse

    if ($vmcx -eq $null)
    {
        Write-Error "Cannot find .vmcx file in "$OldVMPath -ErrorAction Stop
    }

    $newVM = Import-VM -Path $vmcx.FullName -VhdDestinationPath $NewVMPath -Copy -GenerateNewId -VirtualMachinePath $NewVMPath
    
    Add-VMNetworkAdapter -VMName $newVM.Name -SwitchName $ExternalSwitchName


    $importedName = $newVM.Name
    $changedName = $importedName + $(Get-Date)

    Rename-VM $importedName $changedName

    Start-VM $changedName
}

# usage

# CreateVM -VMName test3 -VMRootFolder d:\hyperv -VHDSize 100GB -VMGen 1 -ISOPath D:\ISO\ubuntu-20.04.2-live-server-amd64.iso -CpuCount 4
# ImportVM -NewVMPath D:\Hyper-V\us1 -OldVMPath G:\VMExport\UbuntuServer.Template
