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

resource "coder_script" "droidvnc" {
  agent_id = var.agent_id

  display_name = "droidVNC"
  icon         = "/emojis/1f4f1.png"
  
  script = file("${path.module}/install-droidvnc.sh")

  run_on_start = true
  start_blocks_login = false
}

resource "coder_app" "novnc2" {
  agent_id     = var.agent_id

  display_name = "noVNC (from droidVNC)"
  slug         = "novnc2"
  icon         = "/icon/novnc.svg"
  group        = "(experiment)"

  url = "http://localhost:5800/vnc.html?autoconnect=1&resize=scale&show_dot=1&password=supersecure"

  share     = "owner"
  subdomain = true

  healthcheck {
    url       = "http://localhost:5800/vnc.html"
    interval  = 5
    threshold = 6
  }

  order = 4
}