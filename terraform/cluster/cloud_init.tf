# Local vars to support the cloud-init resource

locals {

  # --- Template Injections ---
  retry_join_json = jsonencode([for m in local.manager_nodes : m.ip])

  nomad_manager_hcl = templatefile("${path.module}/templates/nomad_manager.tftpl", {
    datacenter = var.env.datacenter
  })

  nomad_worker_hcl = templatefile("${path.module}/templates/nomad_worker.tftpl", {
    datacenter = var.env.datacenter
    priority   = local.keepalived_priority
  })

  consul_manager_hcl = templatefile("${path.module}/templates/consul_manager.tftpl", {
    retry_join_json = local.retry_join_json,
    datacenter      = var.env.datacenter
  })

  consul_worker_hcl = templatefile("${path.module}/templates/consul_worker.tftpl", {
    retry_join_json = local.retry_join_json,
    datacenter      = var.env.datacenter
  })
}

# Cloud-init config for each host and role: (Manager, Worker)
# This needs to be available to all the vm hosts 

resource "proxmox_virtual_environment_file" "cloud_init" {
  for_each     = local.all_nodes
  node_name    = var.env.pve_nodes[0]
  datastore_id = var.env.vm.cloud_init_storage
  content_type = "snippets"

  source_raw {
    file_name = "${each.value.name}-setup.yaml"
    data = templatefile("${path.module}/templates/cloud_init.tftpl", {
      hostname           = each.value.name
      role               = each.value.role
      ciuser             = var.env.ciuser
      cipassword         = var.env.cipassword
      sshkey             = trimspace(var.env.sshkeys)
      dns                = var.env.dns
      use_host_storage   = var.env.use_host_storage
      storage_mount      = var.env.storage_mount
      consul_manager_hcl = local.consul_manager_hcl
      consul_worker_hcl  = local.consul_worker_hcl
      nomad_manager_hcl  = local.nomad_manager_hcl
      nomad_worker_hcl   = local.nomad_worker_hcl
    })
  }
}


