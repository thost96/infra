variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "k8s_template_name" {
  description = "Name of the Packer-built k8s VM template to clone"
  type        = string
  default     = "2604-k8s"
}

variable "control_nodes" {
  description = "PVE nodes hosting the control-plane VMs, one control VM per entry"
  type        = list(string)
  default     = ["pve-1", "pve-2", "pve-3"]
}

variable "worker_nodes" {
  description = "PVE nodes hosting the worker VMs, one worker VM per entry"
  type        = list(string)
  default     = ["pve-1", "pve-2"]
}

variable "longhorn_control_node" {
  description = "PVE node whose control-plane VM also gets a dedicated Longhorn disk (third replica / quorum)"
  type        = string
  default     = "pve-3"
}

variable "longhorn_disk_size" {
  description = "Size in GiB of the dedicated Longhorn data disk on the worker VMs and the Longhorn control-plane VM"
  type        = number
  default     = 100
}
