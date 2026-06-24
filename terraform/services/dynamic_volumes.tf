# This resource reads volumes from volumes.auto.tfvars and
# and creates volume resources to be used in Nomad jobs. Volumes can 
# be 1 of 2 types - csi or host. Defined by var.env.storage_type var. 
# Currently the csi storage mode has only been tested with the RocketDuck 
# NFS storage plugin. The host mode exposes dynamic volumes.

data "consul_service" "nomad_workers" {
  name = "nomad-client"
}

data "http" "nomad_nodes" {
  url = "${var.env.nomad_addr}:/v1/nodes"
}

locals {

  mount_point = "/mnt"

  nomad_nodes = [
    for n in jsondecode(data.http.nomad_nodes.response_body) : n
    if n.Status == "ready"
  ]

  # Build a map of node name -> nomad node ID (ready nodes only)
  nomad_node_id_by_name = {
    for n in local.nomad_nodes : n.Name => n.ID
  }

  # Get the Nomad node IDs for our consul-registered workers
  worker_node_ids = [
    for s in data.consul_service.nomad_workers.service :
    local.nomad_node_id_by_name[s.node_name]
    if contains(keys(local.nomad_node_id_by_name), s.node_name)
  ]

  volume_files = [
    for job in local.deployed_jobs :
    "${job}/dynamic_volumes.yaml"
    if fileexists("${local.jobs}/${job}/dynamic_volumes.yaml")
  ]

  all_volumes = length(local.volume_files) > 0 ? merge([
    for f in local.volume_files :
    yamldecode(file("${local.jobs}/${f}"))
  ]...) : {}

  # If a volume specifies nodes, only register on those nodes.
  # Otherwise, register on all worker nodes.
  host_volumes = merge([
    for vol_key, vol_value in local.all_volumes : {
      for node_id in(
        vol_value.nodes != null
        ? [for n in vol_value.nodes : local.nomad_node_id_by_name[n] if contains(keys(local.nomad_node_id_by_name), n)]
        : local.worker_node_ids
      ) :
      "${node_id}-${vol_key}" => {
        node_id     = node_id
        name        = vol_key
        host_path   = "${local.mount_point}/${vol_value.external_id}"
        access_mode = vol_value.access_mode
      }
    }
  ]...)
}

resource "nomad_dynamic_host_volume_registration" "dynamic_volumes" {
  # Only run this if our storage mode is != csi
  for_each = var.env.storage_type == "host" ? local.host_volumes : {}

  node_id   = each.value.node_id
  name      = each.value.name
  host_path = each.value.host_path


  capability {
    access_mode     = each.value.access_mode
    attachment_mode = "file-system"
  }

}
