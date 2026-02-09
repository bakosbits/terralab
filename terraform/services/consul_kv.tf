# This resource reads the map defeined in var.consul_kv.auto.tfvars 
# and defines configuration files stored in Consul KV
locals {
  files         = "${path.module}/consul_kv"
  template_vars = var.env

   # This creates: "consul/path" => "local/file/path"
  kv = merge([
    for job_key, data in var.consul_kv : {
      for filename in data.filenames :
      "${data.path_prefix}${filename}" => {
        source_path = "${path.module}/consul_kv/${job_key}/${filename}"
      }
    }
  ]...)
}

resource "consul_keys" "consul_kv" {
  for_each = local.kv

  key {
    path  = each.key
    # This reaches into /service/consul_kv/<jobname>/file.ext
    value = templatefile(each.value.source_path, local.template_vars)
  }
}
