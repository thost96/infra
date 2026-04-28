# Ubuntu Server Plucky Puffin
# ---
# Packer Template to create an Ubuntu Server 25.04 LTS (Plucky Puffin) on Proxmox

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

source "proxmox-iso" "ubuntu-server-resolute-k8s" {
 
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "${var.proxmox_nodename}"
    vm_name = "ubuntu-server-resolute-k8s"
    template_description = "Ubuntu 26.04 Resolute Raccoon with K8S"

    boot_iso {
         type             = "scsi"
         iso_url          = "https://releases.ubuntu.com/resolute/ubuntu-26.04-live-server-amd64.iso"
         unmount          = true
         iso_storage_pool = "local"
         iso_checksum     = "file:https://releases.ubuntu.com/resolute/SHA256SUMS"
         iso_download_pve = true
    }

    template_name        = "2604-k8s"

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "10G"
        format = "raw"
        storage_pool = "${var.proxmox_vm_store}"
        type = "virtio"
        discard = true
    }

    # VM CPU Settings
    cores = "${var.cpu_nums}"
    
    # VM Memory Settings
    memory = "${var.mem_size}"

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "${var.proxmox_vm_bridge}"
        vlan_tag = "${var.proxmox_vm_vlan}"
        firewall = "false"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "${var.proxmox_vm_store}"

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

    http_directory = "./http" 

    ssh_username = "${var.ssh_username}"
    ssh_password = "${var.ssh_password}"
    # ssh_private_key_file = "~/.ssh/id_rsa"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-resolute-k8s"
    sources = [
      "proxmox-iso.ubuntu-server-resolute-k8s"
    ]

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

    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    provisioner "shell" {
        inline = [
            # Containerd
            "wget https://github.com/containerd/containerd/releases/download/v2.2.1/containerd-2.2.1-linux-amd64.tar.gz",
            "sudo tar Cxzvf /usr/local containerd-2.2.1-linux-amd64.tar.gz",
            # Systemd Service
            "wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service",
            "sudo mkdir -p /usr/local/lib/systemd/system/",
            "sudo cp ./containerd.service /usr/local/lib/systemd/system/",
            "sudo systemctl daemon-reload",
            "sudo systemctl enable --now containerd",
            # runc
            "wget https://github.com/opencontainers/runc/releases/download/v1.4.0/runc.amd64",
            "sudo install -m 755 runc.amd64 /usr/local/sbin/runc",
            # CNI Plugins
            "wget https://github.com/containernetworking/plugins/releases/download/v1.9.0/cni-plugins-linux-amd64-v1.9.0.tgz",
            "sudo mkdir -p /opt/cni/bin",
            "sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.9.0.tgz",
            # K8S Tools
            "sudo apt-get install -y apt-transport-https ca-certificates curl gpg",
            "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
            "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
            "sudo apt-get update",
            "sudo apt-get install -y kubelet kubeadm kubectl",
            "sudo systemctl enable --now kubelet",
            # Routing
            "echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-ipforward.conf",
            "echo 'br_netfilter' | sudo tee /etc/modules-load.d/br_netfilter.conf"
        ]
    }
}
