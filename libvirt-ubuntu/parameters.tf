data "coder_parameter" "cpu_count" {
  name         = "cpu_count"
  display_name = "CPU Count"
  description  = "How many CPUs would you like?"
  default      = "2"
  type         = "string"
  icon         = "/icon/memory.svg"
  mutable      = true

  option {
    name  = "1 CPU"
    value = "1"
  }

  option {
    name  = "2 CPUs"
    value = "2"
  }

  option {
    name  = "4 CPUs"
    value = "4"
  }

  option {
    name  = "8 CPUs"
    value = "8"
  }
}

data "coder_parameter" "ram_amount" {
  name         = "ram_amount"
  display_name = "RAM Amount"
  description  = "How much RAM would you like?"
  default      = "8192"
  type         = "string"
  mutable      = true

  option {
    name = "1 GB"
    value = "1024"
  }
  
  option {
    name = "2 GB"
    value = "2048"
  }

  option {
    name = "4 GB"
    value = "4096"
  }

  option {
    name = "8 GB"
    value = "8192"
  }

  option {
    name = "16 GB"
    value = "16384"
  }
  
  option {
    name = "32 GB"
    value = "32768"
  }
}
