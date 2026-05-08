# VyOS PAcker Template for Proxmox
# Inspired by: 
# https://github.com/juseok1729/homelab/blob/master/packer/vyos-template/vyos-template.pkr.hcl
# https://github.com/juseok1729/homelab/blob/master/ansible/vyos-template/playbook.yml

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
  default = "vyos"
}
variable "ssh_password" {
  type = string
  default = "vyos"
}
variable "build_ip" {
  description = "Packer is missing qemu-guest-agent, so ip discovery doesn't work out of the box"
  type        = string
}
variable "upstream_gateway" {
  description = "Gateway"
  type        = string
}
variable "vm_id" {
  type    = number
  default = 9000
}

variable "shell_provisioner_scripts" {
  type = list(string)
  default = [
    "provisioners/configure.sh",
  ]
}

source "proxmox-iso" "vyos" {
  proxmox_url = "${var.proxmox_api_url}"
  username = "${var.proxmox_api_token_id}"
  token = "${var.proxmox_api_token_secret}"
  # (Optional) Skip TLS Verification
  insecure_skip_tls_verify = true
  node = "${var.proxmox_nodename}"
  vm_id   = var.vm_id
  vm_name = "vyos"
  template_name = "vyos"
  template_description = "VyOS Router"
  boot_iso {
    type             = "scsi"
    iso_url          = "https://github.com/vyos/vyos-nightly-build/releases/download/2026.05.07-0040-rolling/vyos-2026.05.07-0040-rolling-generic-amd64.iso"
    unmount          = true
    iso_storage_pool = "local"
    iso_checksum     = "sha256:42d400a8c59020876ace8c7b6341d850616111e356efe7a82ba47ae146b8fa33"
    iso_download_pve = true 
  }
  qemu_agent = true
  scsi_controller = "virtio-scsi-single"
  disks {
    disk_size = "4G"
    format = "raw"
    storage_pool = "${var.proxmox_vm_store}"
    type = "scsi"
    discard = true
  }
  cpu_type = "host"
  os       = "l26"
  cores = "${var.cpu_nums}"
  memory = "${var.mem_size}"
  network_adapters {
    model = "virtio"
    bridge = "${var.proxmox_vm_bridge}"
    vlan_tag = "${var.proxmox_vm_vlan}"
    firewall = "false"
  } 
  communicator = "ssh"
  ssh_username = "${var.ssh_username}"
  ssh_password = "${var.ssh_password}"
  ssh_host     = var.build_ip
  ssh_timeout  = "20m"
  boot_wait     = "45s"
  boot_command  = [
    "<enter><wait>",
    "vyos<enter><wait3>",
    "vyos<enter><wait3>",
    "install image<enter><wait5>",
    "yes<enter><wait3>",
    "<enter><wait3>",
    "${var.ssh_password}<enter><wait3>",
    "${var.ssh_password}<enter><wait3>",
    "K<enter><wait5>",
    "<enter><wait5>",
    "yes<enter><wait5>",
    "yes<enter><wait5>",
    "<enter><wait10>",
    "reboot<enter><wait5>",
    "yes<enter><wait90>",
    "<enter><wait>",
    "${var.ssh_username}<enter><wait3>",
    "${var.ssh_password}<enter><wait5>",
    "configure<enter><wait3>",
    "set interfaces ethernet eth0 address ${var.build_ip}/24<enter><wait2>",
    "set service ssh port 22<enter><wait2>",
    "set service ssh listen-address 0.0.0.0<enter><wait2>",
    "set protocols static route 0.0.0.0/0 next-hop ${var.upstream_gateway}<enter><wait2>",
    "commit<enter><wait10>",
    "save<enter><wait3>",
    "exit<enter>",
  ]
}

build {
  name = "vyos"
  sources = [ "proxmox-iso.vyos" ]

  provisioner "ansible" {
    playbook_file = "playbook.yml"
    user          = "vyos"
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3",
      "--extra-vars", "ansible_become_pass=${var.ssh_password}",
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo sed -i 's|address \"${var.build_ip}/24\"|address dhcp|' /config/config.boot",
      "nohup bash -c 'sleep 3 && sudo poweroff' </dev/null >/dev/null 2>&1 &"
    ]
    expect_disconnect = true
  }

  post-processor "shell-local" {
    inline = [
      # serial console (Terraform clone 후 qm terminal 가능하게)
      "ssh root@${split(":", split("//", var.proxmox_api_url)[1])[0]} 'qm set ${var.vm_id} --serial0 socket --vga serial0'",
      # cloud-init drive (PVE 호환)
      "ssh root@${split(":", split("//", var.proxmox_api_url)[1])[0]} 'qm set ${var.vm_id} --ide2 ${var.proxmox_vm_store}:cloudinit --agent enabled=1'",
    ]
  }
}
