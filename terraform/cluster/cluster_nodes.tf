# local vars to support the vm resource in proxmox_vm.tf #

locals {

  all_nodes = {
    for node in concat(local.manager_nodes, local.worker_nodes) : node.name => node
  }

  manager_nodes = [
    for i in range(var.manager.count) : {

      name        = format("${var.manager.name}%02d", i + 1)
      ip          = cidrhost(var.global.cidr, var.manager.offset + i)
      target_node = var.pve_nodes[i % length(var.pve_nodes)]
      role        = var.manager.role
      clone       = var.manager.clone
      clone_id    = var.manager.clone_id
      disk_size   = var.manager.disk_size
      cores       = var.manager.cores
      memory      = var.manager.memory
      dns1        = var.global.dns1
    }
  ]

  worker_nodes = [
    for i in range(var.worker.count) : {
             
      name        = format("${var.worker.name}%02d", i + 1)
      ip          = cidrhost(var.global.cidr, var.worker.offset + i)
      target_node = var.pve_nodes[i % length(var.pve_nodes)]
      role        = "worker"
      clone       = "worker-tpl"
      clone_id    = 9002
      disk_size   = 30
      cores       = 12
      memory      = 65536
      dns1        = var.global.dns1      
    }
  ]
}
