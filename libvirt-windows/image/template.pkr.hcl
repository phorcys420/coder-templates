packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

locals {
  hello = fileset("drivers", "{NetKVM,vioscsi,viostor}/w10/amd64/*.{cat,inf,sys}")
}

source "qemu" "windows" {
  iso_url      = var.windows_iso_url
  iso_checksum = var.windows_iso_checksum

  # disk_image = true # used when the iso_url correspons to a raw disk (e.g qcow2)

  # https://wiki.qemu.org/Documentation/Networking#How_to_get_SSH_access_to_a_guest
  # Makes guest's :5985 port accessible from localhost:<SSHHostPort>
  # SSHHostPort is a random available port found by Packer, despite its name it's used for SSH, WinRM and 
  qemuargs = [
    [ "-netdev", "user,hostfwd=tcp::{{ .SSHHostPort }}-:5985,id=forward"],
    [ "-device", "virtio-net,netdev=forward,id=net0"]
  ]

  vm_name = "${var.vm_name}.${var.vm_disk_format}"

  cpus = 4

  # NOTE: this is required for the VM to boot
  # if you don't do this, you will run into ntfs.sys's 0xc0000017 error (Unable to create ramdisk).
  memory = 4096
  
  disk_size   = var.vm_disk_size
  format      = var.vm_disk_format

  #disk_compression   = true
  #disk_discard       = "unmap"
  #skip_compaction    = false
  #disk_detect_zeroes = "unmap"

  machine_type = "q35"
  accelerator  = "kvm"

  output_directory = var.output_directory

  # Using a floppy drive is more consistent than using a CD drive because Windows reserves the A: letter for the first floppy
  # and the chances of another floppy drive being present are very low
  floppy_label = "packer"

  floppy_dirs = [
    "assets",
  # "drivers/guest-agent"
  ]

  # Those are the bare minimum drivers we need for the Windows installer to see the drives
  # and for WinRM to be available from within the virtual network 
  # TODO: try without NetKVM
  floppy_files = fileset(".", "drivers/{NetKVM,vioscsi,viostor}/w10/amd64/*.{cat,inf,sys}")
  
  #floppy_files = setunion(
  #  fileset(".", "drivers/{NetKVM,vioscsi,viostor}/w10/amd64/*.{cat,inf,sys}"),
  #  fileset(".", "drivers/*.{msi,exe}")
  #)

  floppy_content = {
    # the Autounattend.xml file is a way to install Windows automatically, see the following links for more information:
    # https://developer.hashicorp.com/packer/guides/automatic-operating-system-installs/autounattend_windows
    # https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs?view=windows-10
    "Autounattend.xml" = templatefile("assets/_Autounattend.xml", {
      "edition" = var.windows_edition,

      "user_name" = "coder",
      "user_password" = "coder",

      "administrator_user_name" = "Administrateur",
      "administrator_password" = "coderr",

      "inputlocale" = var.windows_input_locale, # <- todo: extend
      "locale"      = var.windows_locale
    })
  }

  communicator = "winrm"

  winrm_timeout           = "40m"
  shutdown_timeout        = "10m"

  winrm_username = "Administrateur"
  winrm_password = "coderr"
  #winrm_port     = 5985

  # TODO: add unattend so that next boot gets installed automatically
  shutdown_command = "C:\\Windows\\System32\\Sysprep\\sysprep.exe /generalize /oobe"
}

build {
  sources = ["source.qemu.windows"]
}
