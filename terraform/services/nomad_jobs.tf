# This resource reads nomad_jobs map from nomad_jobs.auto.tfvars and builds
# job resources in Nomad. You can add per job vars to the map
# e.g. coredns = {version="xxx", cpu=xxx, ram=xxx} 
# and then use those vars in job templates. I would love to have only 1 resource 
# for jobs. To date a job_groups map and more specifically depends_on has been 
# the only way I've found to reliably control services at deployment time. 
# Unfortunatley I can't pass a var or use an unknown index in depends_on

locals {
  jobs         = "${path.module}/nomad_jobs"
  vars = {
    consul_domain = var.env.consul_domain
    storage_mode  = var.env.storage_mode        
    datacenter    = var.env.datacenter
    nomad_url     = var.env.nomad_url
    virtual_ip    = var.env.virtual_ip
    nfs_server    = var.env.nfs_server
    timezone      = var.env.timezone
    domain        = var.env.domain
    uid           = var.env.uid
    gid           = var.env.gid
  }  
}

resource "nomad_job" "initial_services" {
  for_each = var.nomad_jobs.initial_services.jobs
  jobspec  = templatefile("${local.jobs}/${each.key}.hcl", merge(local.vars, each.value))
  detach   = false
  depends_on = [consul_keys.consul_kv, nomad_variable.secrets]
}

resource "nomad_job" "data_services" {
  for_each   = var.nomad_jobs.data_services.jobs
  jobspec    = templatefile("${local.jobs}/${each.key}.hcl", merge(local.vars, each.value))
  detach     = false
  depends_on = [nomad_job.initial_services]
}

resource "nomad_job" "network_services" {
  for_each   = var.nomad_jobs.network_services.jobs
  jobspec    = templatefile("${local.jobs}/${each.key}.hcl", merge(local.vars, each.value))
  detach     = false
  depends_on = [nomad_job.data_services]
}

resource "nomad_job" "logging_services" {
  for_each   = var.nomad_jobs.logging_services.jobs
  jobspec    = templatefile("${local.jobs}/${each.key}.hcl", merge(local.vars, each.value))
  detach     = false
  depends_on = [nomad_job.network_services]
}

resource "nomad_job" "core_services" {
  for_each   = var.nomad_jobs.core_services.jobs
  jobspec    = templatefile("${local.jobs}/${each.key}.hcl", merge(local.vars, each.value))
  detach     = false
  depends_on = [nomad_job.logging_services]
}

resource "nomad_job" "media_services" {
  for_each   = var.nomad_jobs.media_services.jobs
  jobspec    = templatefile("${local.jobs}/${each.key}.hcl", merge(local.vars, each.value))
  detach     = false
  depends_on = [nomad_job.core_services]
}

resource "nomad_job" "final_services" {
  for_each   = var.nomad_jobs.final_services.jobs
  jobspec    = templatefile("${local.jobs}/${each.key}.hcl", merge(local.vars, each.value))
  detach     = false
  depends_on = [nomad_job.media_services]
}