# This resource reads template files from nomad_jobs/*/consul_kv/
# and defines configuration files stored in Consul KV

locals {
  kv = {
    for file in toset(flatten([
      for job in local.deployed_jobs :
      fileset(local.jobs, "${job}/consul_kv/*")
    ])) :
    "${local.vars.lab_name}/${split("/consul_kv/", file)[0]}/${split("/consul_kv/", file)[1]}" => {
      source_path = abspath("${local.jobs}/${file}")
    }
  }
}

resource "consul_keys" "consul_kv" {
  for_each = local.kv
  key {
    path  = each.key
    value = templatefile(each.value.source_path, local.vars)
  }
}
