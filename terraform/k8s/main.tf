### Get Template (created with Packer)
data "proxmox_virtual_environment_vms" "k8s_template" {
  filter {
    name   = "template"
    values = [true]
  }
  filter {
    name   = "name"
    regex  = true
    values = ["^${var.k8s_template_name}$"]
  }
}

output "template_vm_id" {
  description = "VM ID of the used k8s template"
  value       = data.proxmox_virtual_environment_vms.k8s_template.vms[0].vm_id
}

### K8S Control Nodes (one per PVE node)
resource "proxmox_virtual_environment_vm" "control_node" {
  count           = length(var.control_nodes)
  name            = "control-${count.index + 1}"
  node_name       = var.control_nodes[count.index]
  started         = true
  stop_on_destroy = true

  clone {
    vm_id        = data.proxmox_virtual_environment_vms.k8s_template.vms[0].vm_id
    node_name    = data.proxmox_virtual_environment_vms.k8s_template.vms[0].node_name
    datastore_id = "nvme"
    full         = true
  }

  network_device {
    bridge  = "ovs"
    vlan_id = 105
  }

  memory {
    dedicated = 4096 # K8s minimum is 2 GB; 4 GB to also run Longhorn (control-3)
  }

  cpu {
    cores   = 2 # K8s minimum requirement: 2 CPUs
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  disk {
    datastore_id = "nvme"
    interface    = "virtio0"
    discard      = "on"
    size         = 32 # K8s minimum requirement: 32 GB disk
  }

  # Dedicated Longhorn data disk for the third replica/quorum, created only on
  # the control-plane VM that runs on var.longhorn_control_node (pve-3).
  dynamic "disk" {
    for_each = var.control_nodes[count.index] == var.longhorn_control_node ? [1] : []
    content {
      datastore_id = "nvme"
      interface    = "virtio1"
      discard      = "on"
      serial       = "longhorn-data"
      size         = var.longhorn_disk_size
    }
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
}

output "control_node_ids" {
  description = "VM IDs of the control-plane nodes"
  value       = proxmox_virtual_environment_vm.control_node[*].id
}

output "control_ips" {
  description = "IPv4-Adressen (ohne Loopback) der Control-Nodes"
  value = {
    for vm in proxmox_virtual_environment_vm.control_node :
    vm.name => try([for ip in flatten(vm.ipv4_addresses) : ip if !startswith(ip, "127.")][0], null)
  }
}

### K8S Worker Nodes (one per PVE node)
resource "proxmox_virtual_environment_vm" "worker_node" {
  count           = length(var.worker_nodes)
  name            = "worker-${count.index + 1}"
  node_name       = var.worker_nodes[count.index]
  started         = true
  stop_on_destroy = true

  clone {
    vm_id        = data.proxmox_virtual_environment_vms.k8s_template.vms[0].vm_id
    node_name    = data.proxmox_virtual_environment_vms.k8s_template.vms[0].node_name
    datastore_id = "nvme"
    full         = true
  }

  network_device {
    bridge  = "ovs"
    vlan_id = 105
  }

  memory {
    dedicated = 16384 # 16 GiB RAM
  }

  cpu {
    cores   = 8
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  disk {
    datastore_id = "nvme"
    interface    = "virtio0"
    discard      = "on"
    size         = 32 # 32 GB OS disk
  }

  # Dedicated Longhorn data disk (formatted and mounted at /var/lib/longhorn)
  disk {
    datastore_id = "nvme"
    interface    = "virtio1"
    discard      = "on"
    serial       = "longhorn-data"
    size         = var.longhorn_disk_size
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
}

output "worker_node_ids" {
  description = "VM IDs of the worker nodes"
  value       = proxmox_virtual_environment_vm.worker_node[*].id
}

output "worker_ips" {
  description = "IPv4-Adressen (ohne Loopback) der Worker-Nodes"
  value = {
    for vm in proxmox_virtual_environment_vm.worker_node :
    vm.name => try([for ip in flatten(vm.ipv4_addresses) : ip if !startswith(ip, "127.")][0], null)
  }
}
