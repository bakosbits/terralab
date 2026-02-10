# This resource reads the map from nomad_jobs.auto.tfvars and builds
# job resources in Nomad. You can add per job vars to the map
# e.g. coredns = {version="xxx", cpu=xxx, ram=xxx} 
# and then use those vars in job templates.
locals{
  jobs = "${path.module}/nomad_jobs"
  vars  = {
    pve_backup_url = var.env.pve_backup_url
    consul_domain  = var.env.consul_domain
    storage_mode   = var.env.storage_mode        
    datacenter     = var.env.datacenter
    nomad_url      = var.env.nomad_url
    consul_url     = var.env.consul_url
    pfsense_url    = var.env.pfsense_url
    virtual_ip     = var.env.virtual_ip
    nfs_server     = var.env.nfs_server
    secret_id      = var.env.secret_id
    timezone       = var.env.timezone
    pve_url        = var.env.pve_url
    domain         = var.env.domain
    dns1           = var.env.dns1
    dns2           = var.env.dns2
    uid            = var.env.uid
    gid            = var.env.gid
  }    
}

resource "nomad_job" "group_1" {
  for_each = var.nomad_jobs.group_1.jobs
  jobspec  = templatefile("${local.jobs}/${each.key}.hcl", merge(local.vars, each.value))
  detach   = false
  depends_on = [
    nomad_dynamic_host_volume_registration.dynamic_volumes,
    consul_keys.consul_kv, 
    nomad_variable.secrets 
  ]
}

resource "nomad_job" "group_2" {
  for_each   = var.nomad_jobs.group_2.jobs
  jobspec    = templatefile("${local.jobs}/${each.key}.hcl", merge(local.vars, each.value))
  detach     = false
  depends_on = [nomad_job.group_1]
  timeouts {
    create = "10m"
    update = "10m"
  }
}

resource "nomad_job" "group_3" {
  for_each   = var.nomad_jobs.group_3.jobs
  jobspec    = templatefile("${local.jobs}/${each.key}.hcl", merge(local.vars, each.value))
  detach     = false
  depends_on = [nomad_job.group_2]
  timeouts {
    create = "10m"
    update = "10m"
  }
}

resource "nomad_job" "group_4" {
  for_each   = var.nomad_jobs.group_4.jobs
  jobspec    = templatefile("${local.jobs}/${each.key}.hcl", merge(local.vars, each.value))
  detach     = true
  depends_on = [nomad_job.group_3]
  timeouts {
    create = "10m"
    update = "10m"
  }
}
