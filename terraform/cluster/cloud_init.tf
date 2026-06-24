# Local vars to support the cloud-init resource

locals {

  # --- Template Injections ---
  retry_join_json = jsonencode([for m in local.manager_nodes : m.ip])

  vars = {
    retry_join_json = local.retry_join_json,
    priority        = local.keepalived_priority
    datacenter      = var.env.datacenter,
    consul_tld      = var.env.consul_tld
    cidr            = var.env.cidr
    registry_mirror = var.env.registry_mirror
  }

  nomad_manager_hcl  = templatefile("${path.module}/templates/nomad_manager.tftpl", local.vars)
  consul_manager_hcl = templatefile("${path.module}/templates/consul_manager.tftpl", local.vars)
  consul_worker_hcl  = templatefile("${path.module}/templates/consul_worker.tftpl", local.vars)
  registry_mirror    = templatefile("${path.module}/templates/registry_mirror.tftpl", local.vars)
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
      nameserver         = var.env.nameserver
      cephfs_mount       = var.env.cephfs_mount
      consul_manager_hcl = local.consul_manager_hcl
      consul_worker_hcl  = local.consul_worker_hcl
      nomad_manager_hcl  = local.nomad_manager_hcl
      nomad_worker_hcl   = templatefile("${path.module}/templates/nomad_worker.tftpl", merge(local.vars, { priority = try(each.value.keepalived_priority, local.keepalived_priority) }))
      registry_mirror    = local.registry_mirror
    })
  }
}


