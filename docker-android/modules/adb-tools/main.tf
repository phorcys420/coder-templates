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
  description = "The host adb-tools should be listening on."
  default     = "localhost:15555"
}

variable "host_to_proxy" {
  type        = string
  description = "The ADB server websockify should be proxying."
  default     = "localhost:5555"
}

resource "coder_script" "novnc" {
  agent_id     = var.agent_id
  display_name = "adb-tools"
  icon         = "/icon/widgets.svg"

  script = templatefile("${path.module}/run.sh", {
    WEB_SERVER_LISTEN_HOST = var.listen_host,
    ADB_SERVER_HOST = var.host_to_proxy
  })

  run_on_start = true
}

resource "coder_app" "adb-tools" {
  agent_id     = var.agent_id

  display_name = "adb-tools"
  slug         = "adb-tools"
  icon         = "/emojis/1f4f1.png"

  url = "http://${var.listen_host}"

  group = "adb-tools"
  subdomain = true

  order = 4

  healthcheck {
    url       = "http://${var.listen_host}/"
    interval  = 5
    threshold = 6
  }
}