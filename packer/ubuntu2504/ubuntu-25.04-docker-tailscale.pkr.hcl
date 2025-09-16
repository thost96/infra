# Ubuntu Server Plucky Puffin
# ---
# Packer Template to create an Ubuntu Server 25.04 LTS (Plucky Puffin) with Docker and Tailscale on Proxmox

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

variable "ssh_username" {
  type = string
  default = "ubuntu"
}

variable "ssh_password" {
  type = string
  default = "ubuntu"
}

source "proxmox-iso" "ubuntu-server-plucky-docker-tailscale" {
 
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "${var.proxmox_node}"
    vm_name = "ubuntu-server-plucky-docker-tailscale"
    template_description = "Ubuntu 25.04 Plucky Puffin"

    boot_iso {
         type             = "scsi"
         iso_url          = "https://releases.ubuntu.com/25.04/ubuntu-25.04-live-server-amd64.iso"
         unmount          = true
         iso_storage_pool = "local"
         iso_checksum     = "file:https://releases.ubuntu.com/25.04/SHA256SUMS"
    }

    template_name        = "2504-docker-tailscale"

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "10G"
        format = "raw"
        storage_pool = "${var.proxmox_storage}"
        type = "virtio"
    }

    # VM CPU Settings
    cores = "2"
    
    # VM Memory Settings
    memory = "2048" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "ovs"
        vlan_tag = "105"
        firewall = "false"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "${var.proxmox_storage}"

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    http_directory = "./http" 
    #http_bind_address = "10.1.149.166"
    # (Optional) Bind IP Address and Port
    # http_port_min = 8802
    # http_port_max = 8802

    ssh_username = "${var.ssh_username}"
    ssh_password = "${var.ssh_password}"
    # ssh_private_key_file = "~/.ssh/id_rsa"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-plucky-docker-tailscale"
    sources = ["proxmox-iso.ubuntu-server-plucky-docker-tailscale"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt-get -y autoremove --purge",
            "sudo apt-get -y clean",
            "sudo apt-get -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    # Provisioning the VM Template with Docker Installation #4
    provisioner "shell" {
        inline = [
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get update",
            "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
        ]
    }

    # Provisioning the VM Template with Tailscale Installation #5
    # Alternative: https://tailscale.com/kb/1293/cloud-init
    provisioner "shell" {
        inline = [
            "curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/plucky.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null",
            "curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/plucky.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list",
            "sudo apt-get update",
            "sudo apt-get install -y tailscale"
        ]
    }

}
