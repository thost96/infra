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
# Proxmox
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
variable "proxmox_nodename" {
  type = string
  default = ""
}
variable "proxmox_vm_store" {
  type = string
  default = "local-lvm"
}
variable "proxmox_vm_bridge" {
  type = string
  default = "vmbr0"
}
variable "proxmox_vm_vlan" {
  type = string
  default = ""
}

# General
variable "cpu_nums" {
    type = string
    default = "1"
}
variable "mem_size" {
    type = string
    default = "1024"
}
variable "ssh_username" {
  type = string
  default = "ubuntu"
}
variable "ssh_password" {
  type = string
  default = "ubuntu"
}

source "proxmox-iso" "proxmox-ve-9" {
 
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "${var.proxmox_nodename}"
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
        efi_storage_pool = "${var.proxmox_vm_store}"
    }
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"
    disks {
        disk_size = "10G"
        format = "raw"
        storage_pool = "${var.proxmox_vm_store}"
        type = "virtio"
    }

    # VM CPU Settings
    cpu_type = "host"
    cores = "${var.cpu_nums}"
    
    # VM Memory Settings
    memory = "${var.mem_size}"

    vga {
        type   = "qxl"
        memory = 16
    }

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "${var.proxmox_vm_bridge}"
        vlan_tag = "${var.proxmox_vm_vlan}"
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
        "<wait4m>",
        # login.
        "root<enter><wait5s>Install123!<enter><wait5s>",
        # install and start qemu agent
        "rm -f /etc/apt/sources.list.d/{pve-enterprise,ceph}.sources<enter>",
        "apt-get update<enter><wait1m>",
        "apt-get install qemu-guest-agent -y<enter><wait60s>",
        "/etc/init.d/qemu-guest-agent start<enter><wait60s>"
    ]

    # PACKER Autoinstall Settings
    http_directory = "." 
    # http_bind_address = ""
    # (Optional) Bind IP Address and Port
    # http_port_min = 8802
    # http_port_max = 8802
    communicator = "ssh"
    ssh_username = "${var.ssh_username}"
    ssh_password = "${var.ssh_password}"
    ssh_timeout = "30m"
}

# Build Definition to create the VM Template
build {
    name = "proxmox-ve-9"
    sources = [
      "proxmox-iso.proxmox-ve-9"
    ]

    # Provisioning the VM Template in Proxmox #1
    provisioner "shell" {
        inline = [
            "rm /etc/ssh/ssh_host_*",
            "truncate -s 0 /etc/machine-id",
            "apt-get update",
            "apt-get dist-upgrade -y",
            "apt-get -y autoremove --purge",
            "apt-get -y clean",
            "apt-get -y autoclean",
            "echo keyboard-configuration keyboard-configuration/variant select German | debconf-set-selections && echo keyboard-configuration keyboard-configuration/layout select de | debconf-set-selections && dpkg-reconfigure -f noninteractive keyboard-configuration",
            "sync"
        ]
    }
}
