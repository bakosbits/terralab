# This resource reads the map from nomad_jobs.auto.tfvars and builds
# job resources in Nomad. You can add per job vars to the map
# e.g. coredns = {version="xxx", cpu=xxx, ram=xxx} 
# and then use those vars in job templates.
locals {
  jobs = "${path.module}/nomad_jobs"
}

resource "nomad_job" "primary" {
  for_each = var.nomad_jobs.primary.jobs
  jobspec  = templatefile("${local.jobs}/${each.key}.${local.vars.nomad_job_ext}", merge(local.vars, each.value))
  detach   = false
  depends_on = [
    nomad_dynamic_host_volume_registration.dynamic_volumes,
    nomad_csi_volume_registration.nfs_volumes,
    consul_keys.consul_kv,
    nomad_variable.secrets
  ]
  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "nomad_job" "secondary" {
  for_each   = var.nomad_jobs.secondary.jobs
  jobspec    = templatefile("${local.jobs}/${each.key}.${local.vars.nomad_job_ext}", merge(local.vars, each.value))
  detach     = false
  depends_on = [nomad_job.primary]
  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "nomad_job" "tertiary" {
  for_each   = var.nomad_jobs.tertiary.jobs
  jobspec    = templatefile("${local.jobs}/${each.key}.${local.vars.nomad_job_ext}", merge(local.vars, each.value))
  detach     = true
  depends_on = [nomad_job.secondary]
  timeouts {
    create = "15m"
    update = "15m"
  }
}


