# Windows image

## Build flow

1. Packer starts QEMU
2. The VM boots into the Windows ISO
3. Windows loads the `Autounattend.xml` file from the attached floppy disk (see [docs](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/automate-windows-setup?view=windows-10#use-a-usb-flash-drive), Windows installer ISOs support floppy disks, CD drives and USB disks for this but we use floppy disks because they will always be mounted to the A:\ drive)
4. Windows installs itself
5. First logon commands defined in the `Autounattend.xml` file get ran
    1. Enables WinRM
    2. Adds the script that checks for the Coder agent
6. Packer connects to the VM via WinRM
7. Packer sends the shutdown command (sysprep with options)


## Debugging

### Packer

`PACKER_LOG=1`

### Windows

#### Unattend.xml

##### Running setup manually

If nothing happens on boot, you can try arbitrarily passing the unattend file to the setup executable to get an error message.

1. Press Shift+F10 to open a command prompt
2. Run the following command
```
setup.exe /unattend:A:\Autounattend.xml
```

If nothing happens, skip to the next section.

##### Setup logs

Setup logs are located within `X:\Windows\panther`.

Errors will usually be in `X:\Windows\panther\setuperr.log` if it fails early in the boot process.
TODO: add path of the other logfile

You can view log files using `notepad <path>`.