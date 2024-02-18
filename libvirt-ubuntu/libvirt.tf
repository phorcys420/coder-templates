resource "libvirt_cloudinit_disk" "init" {
  name           = lower("coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}-cloudinit.iso")
  user_data      = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = templatefile("${path.module}/cloud-init/user-data.cfg", {
    hostname = lower(data.coder_workspace.me.name),
    password = "coder",
    
    coder_agent_script = base64encode(coder_agent.main.init_script),
    coder_agent_token  = coder_agent.main.token
  })
}

resource "coder_metadata" "libvirt_cloudinit_disk_init" {
  resource_id = libvirt_cloudinit_disk.init.id
  hide        = true
}

# ---

resource "libvirt_pool" "coder" {
  name = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
  type = "dir"
  path = "/tmp/terraform-provider-libvirt-pool-coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
}

resource "libvirt_volume" "boot" {
  name   = "ubuntu-qcow2"
  pool   = libvirt_pool.coder.name
  source = "https://cloud-images.ubuntu.com/releases/23.10/release/ubuntu-23.10-server-cloudimg-amd64.img"
  format = "qcow2"
}

#resource "libvirt_volume" "root" {
#  name             = lower("coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}.qcow2")
#  count            = data.coder_workspace.me./tmp/terraform-provider-libvirt-pool-coderstart_count
#  format           = "qcow2"
#  base_volume_name = "${data.coder_parameter.baseline_image.value}.qcow2"
#  base_volume_pool = "baselines"
#}

#resource "coder_metadata" "libvirt_volume_root" {
#  count       = data.coder_workspace.me.start_count
#  resource_id = libvirt_volume.root[0].id
#  hide        = true
#}

# ---

resource "libvirt_volume" "home" {
  name   = lower("coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}.home.qcow2")
  format = "qcow2"
  pool   = libvirt_pool.coder.name

  size = 20 * pow(1024, 3) # 20 Gigabytes to 21474836480 Bytes
}

resource "coder_metadata" "libvirt_volume_home" {
  resource_id = libvirt_volume.home.id
  hide        = true
}

# ---

resource "libvirt_domain" "main" {
  name       = lower("coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}")
  count      = data.coder_workspace.me.start_count
  memory     = data.coder_parameter.ram_amount.value
  vcpu       = data.coder_parameter.cpu_count.value
  qemu_agent = false # TODO: get this to work (maybe)
  
  cloudinit  = libvirt_cloudinit_disk.init.id

  disk {
    volume_id = libvirt_volume.boot.id
  }

  disk {
    volume_id = libvirt_volume.home.id
  }

  boot_device {
    dev = [ "hd" ]
  }

  #filesystem {
  #  source  = "/var/lib/libvirt/shares/coder-${lower(data.coder_workspace.me.owner)}-${lower(data.coder_workspace.me.name)}"
  #  target  = "out"
  #  readonly = false
  #}

  # TODO: see if this is still the case as this was copied from the example template for the libvirt provider
  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  network_interface {
    network_name = "default"
    #wait_for_lease = true
  }

  # We use a XSL Transform file to modify the VM's XML definition to set the boot disk to be readonly
  # Otherwise, cloud-init will ignore the newly modified cloud-init disk and the Coder agent will use an outdated token
  # Also, we don't want the end users to be able to write to this
  # NOTE: will remove this later, this actually breaks cloud-init
  #xml {
  #  xslt = templatefile("boot-disk-readonly.xsl", {
  #    disk_name = libvirt_volume.boot.name
  #  })
  #}
}

resource "coder_metadata" "libvirt_domain_main" {
  count       = data.coder_workspace.me.start_count
  resource_id = libvirt_domain.main[0].id
  hide        = true
}
