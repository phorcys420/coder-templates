terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "~> 2.8.0"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "android_vm_name" {
  type        = string
  description = "Android VM name."
  default     = "coder"
}

variable "android_device" {
  type        = string
  description = "Android device type ID."
}

variable "android_image" {
  type        = string
  description = "Android OS image."
}

resource "coder_script" "android-emulator" {
  agent_id     = var.agent_id
  display_name = "Android Emulator"
  icon         = "/icon/android-studio.svg"

  script = templatefile("${path.module}/start-vm.sh", {
    ANDROID_VM_NAME : var.android_vm_name,
    ANDROID_DEVICE : var.android_device,
    ANDROID_IMAGE : var.android_image
  })

  run_on_start = true
}

resource "coder_app" "adb-shell" {
  agent_id     = var.agent_id

  display_name = "ADB Shell"
  slug         = "adb-shell"

  command = "adb shell"

  order = 2

  subdomain = false
  share     = "owner"
}
