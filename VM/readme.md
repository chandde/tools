A tool to create VM and import VM easily

1. Download the script
2. in powershell, import it
```poweshell
. .\vm.ps1
```
3. run the command 

# CreateVM #

**Usage**
3. CreateVM
```powershell
CreateVM -VMName UIServerBuild5 -VMRootFolder D:\hyperv -VHDSize 200GB -VMGen 2 -ISOPath 'F:\ISO\Windows 10 20H2.iso' -CpuCount 6
```

**Configuration**
1. specify your ISO path, the script also add Dvd to the VM and set the Dvd as boot drive automatically
2. dynamic memory is turned on by default
3. after configuration it'll boot the VM automatically

**Note**

The tool assumes you already have an "External" Virtual Switch on the machine, and it locates the first "External" switch and uses it for the VM.


# ImportVM #
For my personal usage, I created the VM templates from one machine and export from another machine, I got error the virtual network adapter cannot be found, so when I make the VM template and before exporting, I removed the virtual NIC from the VM. So this ImportVM tool helps me add a nic back, and rename it.

**Usage**
1. Create your VM template and wait for the OS installation complete
2. Remove Virtual NIC or any thing you don't need when importing
3. Export VM
4. Import VM with below command
```powershell
ImportVM -NewVMPath D:\Hyper-V\us1 -OldVMPath G:\VMExport\UbuntuServer.Template
# NewVMPath is the place where hyper-v exported everything (including three subfolders: snapshots, VHDs, and VMs) and the tool locates the vmcx file from the provided root.
```

**Feature**

This command searches "External" virtual switches, and mounts a virtual NIC from the switch to the imported VM
This command also add a timestamp to the imported VM name and start it. 

**Note**

A lot VM Powershell commands deal with VM name instead of ID, giving the new VM an unique ID will be helpful.
