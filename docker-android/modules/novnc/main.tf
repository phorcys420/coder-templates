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

variable "listen_host" {
  type        = string
  description = ""
}

variable "host_to_proxy" {
  type        = string
  description = ""
}

variable "coder_app_uri_parameters" {
  type        = string
  description = "URI query parameters for noVNC."
  default = "?resize=scale&show_dot=1"
}

variable "coder_app_display_name" {
  type        = string
  description = ""
  default     = "noVNC"
}

resource "coder_script" "android-emulator" {
  agent_id     = var.agent_id
  display_name = "noVNC"
  icon         = "/icon/novnc.svg"

  script = templatefile("${path.module}/run.sh", {
    NOVNC_LISTEN_HOST   = var.listen_host,
    NOVNC_HOST_TO_PROXY = var.host_to_proxy
  })

  run_on_start = true
}

resource "coder_app" "novnc" {
  agent_id     = var.agent_id

  display_name = var.coder_app_display_name
  slug         = "novnc"
  icon         = "/icon/novnc.svg"

  url = "http://${var.listen_host}/${var.coder_app_uri_parameters}"

  # TODO: make variable for those
  share     = "owner"
  subdomain = true

  order = 3

  healthcheck {
    url       = "http://${var.listen_host}/"
    interval  = 5
    threshold = 6
  }
}