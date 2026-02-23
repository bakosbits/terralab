# local vars to support the vm resource in proxmox_vm.tf #

locals {

  keepalived_priority = 100

  all_nodes = {
    for node in concat(local.manager_nodes, local.worker_nodes) : node.name => node
  }

  manager_nodes = [
    for i in range(var.env.manager.count) : {

      vmid        = var.env.start_vmid + i
      name        = format("${var.env.manager.name}%02d", i + 1)
      ip          = cidrhost(var.env.cidr, var.env.manager.offset + i)
      target_node = var.env.pve_nodes[i % length(var.env.pve_nodes)]
      role        = "manager"
      clone       = var.env.manager.clone
      clone_id    = var.env.manager.clone_id
      disk_size   = var.env.manager.disk_size
      cores       = var.env.manager.cores
      memory      = var.env.manager.memory
      dns         = var.env.nameserver
    }
  ]

  worker_nodes = [
    for i in range(var.env.worker.count) : {

      vmid        = var.env.start_vmid + var.env.manager.count + i
      name        = format("${var.env.worker.name}%02d", i + 1)
      ip          = cidrhost(var.env.cidr, var.env.worker.offset + i)
      target_node = var.env.pve_nodes[i % length(var.env.pve_nodes)]
      role        = "worker"
      clone       = var.env.worker.clone
      clone_id    = var.env.worker.clone_id
      disk_size   = var.env.worker.disk_size
      cores       = var.env.worker.cores
      memory      = var.env.worker.memory
      dns         = var.env.nameserver

      keepalived_priority = 100 + (i * 25)

    }
  ]
}
