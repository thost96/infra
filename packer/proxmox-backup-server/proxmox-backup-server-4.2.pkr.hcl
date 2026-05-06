# Guide: https://github.com/rgl/proxmox-backup-server/blob/main/proxmox-backup-server.pkr.hcl
# Guide: https://github.com/jloehel/pmg-packer-image/blob/main/pmg80.pkr.hcl 

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
  default = "nvme"
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
    default = "2"
}
variable "mem_size" {
    type = string
    default = "2048"
}
variable "ssh_username" {
  type = string
  default = "root"
}
variable "ssh_password" {
  type = string
  default = "Install123!"
}
variable "shell_provisioner_scripts" {
  type = list(string)
  default = [
    "provisioners/network.sh",
    "provisioners/localisation.sh",
  ]
}

source "proxmox-iso" "proxmox-backup-server-amd64" {
  proxmox_url = "${var.proxmox_api_url}"
  username = "${var.proxmox_api_token_id}"
  token = "${var.proxmox_api_token_secret}"
  # (Optional) Skip TLS Verification
  insecure_skip_tls_verify = true
  node = "${var.proxmox_nodename}"
  vm_name              = "pbs"
  template_name        = "pbs-4.2"
  template_description = "Proxmox Backup Server 4.2"
  boot_iso {
    type             = "scsi"
    iso_url          = "https://enterprise.proxmox.com/iso/proxmox-backup-server_4.2-1.iso"
    unmount          = true
    iso_storage_pool = "local"
    iso_checksum     = "file:https://enterprise.proxmox.com/iso/proxmox-backup-server_4.2-1.iso.sha256"
    iso_download_pve = true
  }
  qemu_agent = true
  scsi_controller = "virtio-scsi-pci"
  disks {
    disk_size = "32G"
    format = "raw"
    storage_pool = "${var.proxmox_vm_store}"
    type = "scsi"
    discard = true
  }
  cpu_type = "host"
  cores = "${var.cpu_nums}"
  memory = "${var.mem_size}"
  network_adapters {
      model = "virtio"
      bridge = "${var.proxmox_vm_bridge}"
      vlan_tag = "${var.proxmox_vm_vlan}"
      firewall = "false"
  } 
  machine          = "q35"
  bios             = "ovmf"
  os               = "l26"
  efi_config {
    efi_storage_pool = "${var.proxmox_vm_store}"
  }
  communicator = "ssh"
  ssh_username = "${var.ssh_username}"
  ssh_password = "${var.ssh_password}"
  ssh_timeout  = "20m"

  boot_wait        = "10s"
  boot_command = [
    "<enter>",                                                // Gaphical UI Installer
    "<wait30>",                                               // waiting for dhcp etc. 
    "<leftAltOn>g<leftAltOff><wait>",                         // accept eula
    "<leftAltOn>n<leftAltOff><wait10>",                       // use default disk format             
    "United Sta<wait2><enter><wait5>",                        // Country selection
    "<tab><wait2><enter><wait2><up><wait2><enter>",           // Timezone + Keyboard selection
    "<leftAltOn>n<leftAltOff><wait10>",                       // Next Page
    "${var.ssh_password}<wait3><tab>",                        // Password
    "${var.ssh_password}<wait3><tab>",                        // Confirm
    "mail@pbs.local<wait3>",                                  // Email
    "<leftAltOn>n<leftAltOff><wait10>",                       // Next Page
    "pbs.local<wait3>",                                       // Hostname (FQDN)
    "<leftAltOn>n<leftAltOff><wait10>",                       // Next Page
    "<leftAltOn>i<leftAltOff><wait120>",                      // Install
    "${var.ssh_username}<wait3><enter><wait>",                // User
    "${var.ssh_password}<wait3><enter>",                      // Password
    "<wait5>rm -f /etc/apt/sources.list.d/pbs-enterprise.sources<enter>",
    "apt-get update<enter><wait1m>",
    // PVE specific 
    "apt-get install -y qemu-guest-agent<enter><wait1m>",
    "systemctl enable --now qemu-guest-agent<enter><wait30s>",
  ]
}

build {
  sources = [
    "source.proxmox-iso.proxmox-backup-server-amd64",
  ]

  provisioner "shell" {
    expect_disconnect = true
    scripts = var.shell_provisioner_scripts
  }

}