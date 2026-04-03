variable "proxmox_endpoint" {
    type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}

variable "proxmox_node" {
  type = string
  default = "pve"
}

variable "k8s_template_vm_id" {
    type = number
    default = 0
}
