# These resources read job files in nomad_jobs 
# and builds a job resources in Nomad. 
locals {
  jobs = "${path.module}/nomad_jobs"

}

resource "nomad_job" "core" {
  for_each = toset(var.nomad_jobs.core.jobs)
  jobspec  = templatefile("${local.jobs}/${each.value}.hcl", local.vars)
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


resource "nomad_job" "primary" {
  for_each   = toset(var.nomad_jobs.primary.jobs)
  jobspec    = templatefile("${local.jobs}/${each.value}.hcl", local.vars)
  detach     = false
  depends_on = [nomad_job.core]
  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "nomad_job" "secondary" {
  for_each   = toset(var.nomad_jobs.secondary.jobs)
  jobspec    = templatefile("${local.jobs}/${each.value}.hcl", local.vars)
  detach     = false
  depends_on = [nomad_job.primary]
  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "nomad_job" "tertiary" {
  for_each   = toset(var.nomad_jobs.tertiary.jobs)
  jobspec    = templatefile("${local.jobs}/${each.value}.hcl", local.vars)
  detach     = true
  depends_on = [nomad_job.secondary]
  timeouts {
    create = "15m"
    update = "15m"
  }
}





