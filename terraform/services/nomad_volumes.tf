resource "nomad_csi_volume_registration" "volumes" {
  for_each    = var.volumes  
  plugin_id   = "nfs"
  name        = each.key 
  volume_id   = each.value.volume_id
  external_id = each.value.external_id

  capability {
    access_mode     = each.value.access_mode
    attachment_mode = "file-system"
  }

  depends_on            = [nomad_job.core_services]
  deregister_on_destroy = true
}

