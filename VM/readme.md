A tool to create VM and import VM easily, mainly uses HyperV powershell commands.

1. Download the script
2. in powershell, import it
```poweshell
. .\vm.ps1
```
3. run the command `CreateVM` or `ImportVM` accordingly.

# CreateVM #

I use this command to ease the process to create a VM with specific size, CPU cores, RAM and specify an ISO file.

1. specify your ISO path, the script also add Dvd to the VM and set the Dvd as boot drive
2. dynamic memory is turned on by default
3. after configuration it'll boot the VM
4. The tool assumes you already have an "External" Virtual Switch on the machine, and it locates the first "External" switch and uses it for the VM.

**Usage**
```powershell
CreateVM -VMName UIServerBuild5 -VMRootFolder D:\hyperv -VHDSize 200GB -VMGen 2 -ISOPath 'F:\ISO\Windows 10 20H2.iso' -CpuCount 6
```

# ImportVM #
This tool helps importing a VM, have it up and running in seconds, with a few perks. I now have 4 baseline images: Ubuntu Desktop, Ubuntu Server, Win10 with my MSA, Win10 with my work AAD account. I can easily spin up a new VM, and the creds I already configured on the exported VMs just work.

**Prerequisites**
1. Create a VM (the CreateVM command comes in handy)
2. Set up the VM, complete OS install
3. Shutdown
4. Remove any auto checkpoints (to save some disk space)
5. Remove ISO, DVD, anything you won't need. **Also remove virtual NIC**. Otherwise you may get error the nic cannot be found error, if you're importing from another machine.
6. Export the VM. 

**Usage**

Import the VM from anywhere with below command, this command copies the VM with new ID.
```powershell
ImportVM -NewVMPath D:\Hyper-V\us1 -OldVMPath G:\VMExport\UbuntuServer.Template
```
* NewVMPath is will be used for both new VM and new VHD
* OldVMPath is the root folder for the exported VM, the folder that has 3 subfolders: VHD, VM and Snapshots. The tool will find the vmcx and vhd files from this root. 

**Note**

1. This command also add a timestamp to the imported VM name and start it. Often VM Powershell commands deal with VM by name instead of ID, and VM import always uses the same VM name from export, this tool adds a timestamp to the VM name so any operation on the VM won't impact other existing ones.
2. This tool like CreateVM, searches for "External" switches and adds a virtual NIC to the imported VM. If the exported VM has virtual Nic, it'll often fail the import on a different machine.


# To do #
I need a way to run post-import scripts on the new imported VMs, e.g. get IP address, change hostname in SSH, etc..
