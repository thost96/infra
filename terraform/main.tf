### Get Template (created with Packer)
data "proxmox_virtual_environment_vms" "k8s_template" {
  filter {
    name   = "template"
    values = [true]
  }
  filter {
    name   = "name"
    regex  = true
    values = ["^ubuntu-24.04-k8s$"]
  }
}

output "template" {
  value = data.proxmox_virtual_environment_vms.k8s_template.id
}

### K8S Control Nodes
resource "proxmox_virtual_environment_vm" "control_node" {
  count     = 3
  # Later: Place on indifidual PVE Nodes
  name      = "control-${count.index + 1}"
  node_name = var.proxmox_node
  started     = true
  stop_on_destroy = true

  clone {
    vm_id   = var.k8s_template_vm_id #proxmox_virtual_environment_vms.k8s_template.vm[0].vm_id
    full    = true
  }

  network_device {
    bridge  = "ovs"
    vlan_id = 105
  }

  memory {
    dedicated = 2048  # Total memory available to VM
  }

  cpu {
    cores   = 2
    sockets = 1
    type  =  "x86-64-v2-AES"
  }

  disk {
    datastore_id = "nvme"
    interface    = "virtio0"
    discard      = "on"
    size         = 20
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "nvme"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  lifecycle {
    ignore_changes = [

    ]
  }

}

output "control_node_ids" {
  value = proxmox_virtual_environment_vm.control_node[*].id
}

output "vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.control_node[*].ipv4_addresses[1][0]
}

### K8S Worker Nodes
resource "proxmox_virtual_environment_vm" "worker_node" {
  count     = 2
  # Later: Place on indifidual PVE Nodes
  name      = "worker-${count.index + 1}"
  node_name = var.proxmox_node
  started     = true
  stop_on_destroy = true

  clone {
    vm_id   = var.k8s_template_vm_id #proxmox_virtual_environment_vms.k8s_template.vm[0].vm_id
    full    = true
  }

  network_device {
    bridge  = "ovs"
    vlan_id = 105
  }

  memory {
    dedicated = 16384  # Total memory available to VM
  }

  cpu {
    cores   = 8
    sockets = 1
    type  =  "x86-64-v2-AES"
  }

  disk {
    datastore_id = "nvme"
    interface    = "virtio0"
    discard      = "on"
    size         = 40
  }

  agent {
    enabled = true
  }

  initialization {
    datastore_id = "nvme"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  lifecycle {
    ignore_changes = [

    ]
  }

}

output "control_ips" {
  value = local.control_ips
  description = "IPs der Control-Nodes"
}

output "worker_ips" {
  value = local.worker_ips
  description = "IPs der Worker-Nodes"
}
