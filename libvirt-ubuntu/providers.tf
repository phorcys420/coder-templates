terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }

    libvirt = {
      source = "dmacvicar/libvirt"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

provider "coder" {}
provider "libvirt" {}
