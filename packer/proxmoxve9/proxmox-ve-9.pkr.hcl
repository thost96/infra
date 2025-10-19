# Proxmox VE 9
# ---
# Packer Template to create an Proxmox VE 9 (Nested) on Proxmox
# Inspired by https://github.com/rgl/proxmox-ve/blob/master/proxmox-ve.pkr.hcl

packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_api_url" {
  type = string
  default = ""
}

variable "proxmox_api_token_id" {
  type = string
  default = ""
}

variable "proxmox_api_token_secret" {
  type = string
  default = ""
  sensitive = true
}

variable "proxmox_node" {
  type = string
  default = ""
}

variable "proxmox_storage" {
  type = string
  default = "local-lvm"
}

# variable "ssh_username" {
#   type = string
#   default = "ubuntu"
# }

# variable "ssh_password" {
#   type = string
#   default = "ubuntu"
# }

source "proxmox-iso" "proxmox-ve-9" {
 
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "${var.proxmox_node}"
    vm_name = "proxmox-ve-9"
    template_description = "Proxmox VE 9 (Nested)"

    boot_iso {
         type             = "scsi"
         iso_url          = "http://download.proxmox.com/iso/proxmox-ve_9.0-1.iso"
         unmount          = true
         iso_storage_pool = "local"
         iso_checksum     = "file:http://download.proxmox.com/iso/SHA256SUMS"
    }

    template_name         = "pve9"
    os                    = "l26"
    machine               = "q35"
    bios                  = "ovmf"
    efi_config {
        efi_storage_pool = "${var.proxmox_storage}"
    }
    qemu_agent = false

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"
    disks {
        disk_size = "10G"
        format = "raw"
        storage_pool = "${var.proxmox_storage}"
        type = "virtio"
    }

    # VM CPU Settings
    cpu_type = "host"
    cores = "2"
    
    # VM Memory Settings
    memory = "2048" 

    vga {
        type   = "qxl"
        memory = 16
    }

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "ovs"
        vlan_tag = "105"
        firewall = "false"
    } 

    # PACKER Boot Commands
    boot_wait = "10s"
    boot_command = [
        # select Advanced Options.
        "<end><enter>",
        # select Install Proxmox VE (Automated).
        "<down><down><down><enter>",
        # wait for the shell prompt.
        "<wait30s>",
        # do the installation.
        # "proxmox-fetch-answer partition proxmox-ais >/run/automatic-installer-answers<enter><wait>exit<enter>",
        "proxmox-fetch-answer http http://{{ .HTTPIP }}:{{ .HTTPPort }}/answer.toml >/run/automatic-installer-answers<enter><wait>exit<enter>",
        # wait for the installation to finish.
        "<wait4m>"
        # login.
        # "root<enter><wait5s>Install123!<enter><wait5s>",
        # update (de keyboard layout error)
        # "rm -f /etc/apt/sources.list.d/{pve-enterprise,ceph}.sources<enter>",
        # "apt-get update<enter><wait1m>",
        # "apt-get dist-upgrade -y<enter><wait60s>"
    ]
    shutdown_command = "poweroff"

    # PACKER Autoinstall Settings
    http_directory = "." 
    # http_bind_address = ""
    # (Optional) Bind IP Address and Port
    # http_port_min = 8802
    # http_port_max = 8802
    communicator = "none"
    # ssh_username = "root"
    # ssh_password = "${var.ssh_password}"
    # ssh_private_key_file = "~/.ssh/id_rsa"
    # Raise the timeout, when installation takes longer
    # ssh_timeout = "30m"
}

# Build Definition to create the VM Template
build {
    name = "proxmox-ve-9"
    sources = [
      "proxmox-iso.proxmox-ve-9"
    ]
}
