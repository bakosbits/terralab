# This resource reads from volumes from volumes.auto.tfvars and
# and creates volume resources to be used in Nomad jobs. Volumes can 
# be 1 of 2 types - csi or host. Defined by the storage_mode var. Currently the
# csi storage mode has only been tested with the RocketDuck nfs storage plugin


data "consul_service" "nomad_workers" {
  name = "nomad-client"
}

locals {
  # Access the 'service' attribute, which is the list from the consul_service
  worker_node_ids = [
    for s in data.consul_service.nomad_workers.service : s.node_id
  ]

  # 2. Map volumes to these specific IDs
  host_volumes = merge([
    for node_id in local.worker_node_ids : {
      for vol_key, vol_value in var.volumes :
      "${node_id}-${vol_key}" => {
        node_id     = node_id
        name        = vol_key
        host_path   = "${var.env.root_path}${vol_key}"
        access_mode = vol_value.access_mode
      }
    }
  ]...)
}


resource "nomad_dynamic_host_volume_registration" "dynamic_volumes" {
  # Only run this if we are NOT in (NFS) mode
  for_each = var.env.storage_mode == "host" ? local.host_volumes : {}

  node_id   = each.value.node_id
  name      = each.value.name
  host_path = each.value.host_path

  capability {
    access_mode     = each.value.access_mode
    attachment_mode = "file-system"
  }

  depends_on = [nomad_variable.secrets]
}


resource "nomad_csi_volume_registration" "nfs_volumes" {
  for_each    = var.env.storage_mode == "csi" ? var.volumes : {}
  plugin_id   = "nfs"
  name        = each.key
  volume_id   = each.value.volume_id
  external_id = each.value.external_id

  capability {
    access_mode     = each.value.access_mode
    attachment_mode = "file-system"
  }

  deregister_on_destroy = true
  depends_on            = [nomad_variable.secrets]  
}
