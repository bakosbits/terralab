# This resource reads template files from the consul_kv directory
# and defines configuration files stored in Consul KV

locals {
  consul_kv_dir = "${path.module}/consul_kv"

  kv = {
    for file in fileset(local.consul_kv_dir, "*/*") :
    "${local.vars.lab_name}/${file}" => {
      source_path = abspath("${local.consul_kv_dir}/${file}")
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
