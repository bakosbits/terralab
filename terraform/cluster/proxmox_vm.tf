#####################################################################
# the primary resource for creating consul, nomad and coredns hosts #
#####################################################################
resource "proxmox_virtual_environment_vm" "vm" {
  for_each  = local.all_nodes
  name      = each.value.name
  node_name = each.value.target_node

  # the cloning configuration
  clone {
    vm_id     = each.value.clone_id
    node_name = var.vm.pve_nodes[2]
    full      = var.vm.full_clone
  }

  cpu {
    type  = var.vm.cpu_type
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  agent {
    enabled = var.vm.agent_enabled
  }

  network_device {
    bridge  = var.vm.bridge
    model   = var.vm.network_model
    vlan_id = var.vm.vlan_id 
  }

  disk {
    datastore_id = var.vm.storage
    interface    = var.vm.disk_interface
    size         = each.value.disk_size
    iothread     = var.vm.disk_iothread
    discard      = var.vm.disk_discard
    ssd          = var.vm.disk_ssd
  }


  initialization {

    datastore_id = var.vm.storage
    interface    = var.vm.cloudinit_interface

    user_account {
      username = var.global.ciuser
      password = var.global.cipassword
      keys     = [var.global.sshkeys]
    }

    dns {
      servers = [each.value.dns1]
      domain  = var.global.internal_domain
    }

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = cidrhost(var.global.cluster_cidr, 1)
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init[each.key].id
  }

  depends_on = [proxmox_virtual_environment_file.cloud_init]
}
