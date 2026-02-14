# The primary resource for creating consul, nomad and coredns hosts

resource "proxmox_virtual_environment_vm" "vm" {
  for_each  = local.all_nodes
  name      = each.value.name
  node_name = each.value.target_node
  vm_id     = each.value.vmid

  # the cloning configuration
  clone {
    vm_id     = each.value.clone_id
    node_name = var.env.pve_nodes[2]
    full      = var.env.vm.full_clone
  }

  cpu {
    type  = var.env.vm.cpu_type
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  agent {
    enabled = var.env.vm.agent_enabled
  }

  network_device {
    bridge  = var.env.vm.bridge
    model   = var.env.vm.network_model
    vlan_id = var.env.vm.vlan_id
  }

  disk {
    datastore_id = var.env.vm.vm_storage
    interface    = var.env.vm.disk_interface
    size         = each.value.disk_size
    iothread     = var.env.vm.disk_iothread
    discard      = var.env.vm.disk_discard
    ssd          = var.env.vm.disk_ssd
  }


  initialization {

    datastore_id = var.env.vm.vm_storage
    interface    = var.env.vm.cloudinit_interface

    user_account {
      username = var.env.ciuser
      password = var.env.cipassword
      keys     = [var.env.sshkeys]
    }

    dns {
      servers = [each.value.dns]
      domain  = var.env.domain
    }

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = cidrhost(var.env.cidr, 1)
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init[each.key].id
  }

  depends_on = [proxmox_virtual_environment_file.cloud_init]
}
