variable "output_directory" {
    type    = string
    default = "Windows"
}

variable "vm_name" {
    type    = string
    default = "Windows"
}

variable "vm_disk_size" {
    type    = string
    default = "20000M"
}

variable "vm_disk_format" {
    type    = string
    default = "raw"
}


variable "windows_iso_url" {
    type    = string
    default = "19041.1.191206-1406.VB_RELEASE_CLIENTMULTI_X64FRE_FR-FR.ISO"
}

variable "windows_iso_checksum" {
    type    = string
    default = "none"
}

variable "windows_edition" {
    type    = string
    default = "Windows 10 Professionnel"
}

variable "windows_input_locale" {
    type    = string
    default = "0409:00000409"
}

# TODO add all locale options
variable "windows_locale" {
    type = string
    default = "fr-FR"
}