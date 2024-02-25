locals {
  pools = {
    images = libvirt_pool.coder-imgs.name
    data   = libvirt_pool.coder-data.name
    temp   = "default"
  }
}

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

resource "libvirt_pool" "coder-imgs" {
  name = "coder-imgs-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
  type = "dir"
  path = "/tmp/terraform-provider-libvirt-pool-coder-imgs-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
}

resource "libvirt_volume" "boot" {
  name   = "ubuntu"
  source = "https://cloud-images.ubuntu.com/releases/23.10/release/ubuntu-23.10-server-cloudimg-amd64.img"

  format = "qcow2"
  pool   = local.pools.images
}

resource "libvirt_volume" "root" {
  name  = lower("coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}-root.qcow2")
  count = data.coder_workspace.me.start_count

  format = "qcow2"
  pool   = local.pools.temp

  base_volume_name = libvirt_volume.boot.name
  base_volume_pool = local.pools.images
}

resource "coder_metadata" "libvirt_volume_root" {
  count       = data.coder_workspace.me.start_count
  resource_id = libvirt_volume.root[0].id
  hide        = true
}

# ---

resource "libvirt_pool" "coder-data" {
  name = "coder-data-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
  type = "dir"
  path = "/tmp/terraform-provider-libvirt-pool-coder-data-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
}

resource "libvirt_volume" "home" {
  name = lower("coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}-home.qcow2")

  format = "qcow2"
  pool   = libvirt_pool.coder-data.name

  size = 20 * pow(1024, 3) # 20 Gigabytes to 21474836480 Bytes
}

resource "coder_metadata" "libvirt_volume_home" {
  resource_id = libvirt_volume.home.id
  hide        = true
}

# ---

resource "libvirt_domain" "main" {
  name  = lower("coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}")
  count = data.coder_workspace.me.start_count

  memory = data.coder_parameter.ram_amount.value
  vcpu   = data.coder_parameter.cpu_count.value
  
  cloudinit = libvirt_cloudinit_disk.init.id

  disk {
    volume_id = libvirt_volume.root[0].id
  }

  disk {
    volume_id = libvirt_volume.home.id
  }

  boot_device {
    dev = [ "hd" ]
  }

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
    # we wait for the VM to be granted a DHCP lease so that Coder doesn't start waiting for the agent too early
    wait_for_lease = true
  }
}

resource "coder_metadata" "libvirt_domain_main" {
  count       = data.coder_workspace.me.start_count
  resource_id = libvirt_domain.main[0].id
  hide        = true
}
