# This resource reads volumes from volumes.auto.tfvars and
# and creates volume resources to be used in Nomad jobs. Volumes can 
# be 1 of 2 types - csi or host. Defined by var.env.storage_type var. 
# Currently the csi storage mode has only been tested with the RocketDuck 
# NFS storage plugin. The host mode exposes dynamic volumes.

locals {
  nfs_volumes = merge([
    for job in local.deployed_jobs :
    yamldecode(file("${local.jobs}/${job}/nfs_volumes.yaml"))
    if fileexists("${local.jobs}/${job}/nfs_volumes.yaml")
  ]...)
}


resource "nomad_csi_volume_registration" "nfs_volumes" {
  for_each    = local.nfs_volumes
  plugin_id   = "nfs"
  name        = each.key
  volume_id   = each.key
  external_id = each.value.external_id

  capability {
    access_mode     = each.value.access_mode
    attachment_mode = "file-system"
  }

  deregister_on_destroy = true
}
