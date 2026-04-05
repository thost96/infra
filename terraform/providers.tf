terraform {
  required_providers {
    proxmox   = {
      source  = "bpg/proxmox"
      version = "0.100.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true
}
