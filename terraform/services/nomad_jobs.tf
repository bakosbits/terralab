# These resources read job files in nomad_jobs 
# and builds a job resources in Nomad. 
locals {
  jobs = "${path.module}/nomad_jobs"

  backend_storage_jobs = {
    for f in fileset("${local.jobs}/backend_storage", "*.hcl") : 
    replace(f, ".hcl", "") => f
  }

  core_jobs = {
    for f in fileset("${local.jobs}/core", "*.hcl") : 
    replace(f, ".hcl", "") => f
  }

  games_jobs = {
    for f in fileset("${local.jobs}/games", "*.hcl") : 
    replace(f, ".hcl", "") => f
  }

  multimedia_jobs = {
    for f in fileset("${local.jobs}/multimedia", "*.hcl") : 
    replace(f, ".hcl", "") => f
  }

  access_jobs = {
    for f in fileset("${local.jobs}/access", "*.hcl") : 
    replace(f, ".hcl", "") => f
  }

  observability_jobs = {
    for f in fileset("${local.jobs}/observability", "*.hcl") : 
    replace(f, ".hcl", "") => f
  }

  productivity_jobs = {
    for f in fileset("${local.jobs}/productivity", "*.hcl") : 
    replace(f, ".hcl", "") => f
  }

  security_jobs = {
    for f in fileset("${local.jobs}/security", "*.hcl") : 
    replace(f, ".hcl", "") => f
  }

  smart_home_jobs = {
    for f in fileset("${local.jobs}/smart_home", "*.hcl") : 
    replace(f, ".hcl", "") => f
  }


}

resource "nomad_job" "core" {

  for_each = local.core_jobs
  jobspec  = templatefile("${local.jobs}/core/${each.key}.hcl", local.vars)
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

resource "nomad_job" "backend_storage" {

  for_each = local.backend_storage_jobs
  jobspec  = templatefile("${local.jobs}/backend_storage/${each.key}.hcl", local.vars)
  detach   = false
  
  depends_on = [ nomad_job.core ]
  
  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "nomad_job" "access" {

  for_each = local.access_jobs
  jobspec  = templatefile("${local.jobs}/access/${each.key}.hcl", local.vars)
  detach   = false
  
  depends_on = [ nomad_job.backend_storage ]
  
  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "nomad_job" "observability" {

  for_each = local.observability_jobs
  jobspec  = templatefile("${local.jobs}/observability/${each.key}.hcl", local.vars)
  detach   = false
  
  depends_on = [ nomad_job.access ]
  
  timeouts {
    create = "15m"
    update = "15m"
  }
}


resource "nomad_job" "smart_home" {

  for_each = local.smart_home_jobs
  jobspec  = templatefile("${local.jobs}/smart_home/${each.key}.hcl", local.vars)
  detach   = false
  
  depends_on = [ nomad_job.observability ]

  timeouts {
    create = "15m"
    update = "15m"
  }
}


resource "nomad_job" "productivity" {

  for_each = local.productivity_jobs
  jobspec  = templatefile("${local.jobs}/productivity/${each.key}.hcl", local.vars)
  detach   = false
  
  depends_on = [ nomad_job.smart_home ]
  
  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "nomad_job" "multimedia" {

  for_each = local.multimedia_jobs
  jobspec  = templatefile("${local.jobs}/multimedia/${each.key}.hcl", local.vars)
  detach   = false
  
  depends_on = [ nomad_job.productivity ]
  
  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "nomad_job" "games" {

  for_each = local.games_jobs
  jobspec  = templatefile("${local.jobs}/games/${each.key}.hcl", local.vars)
  
  depends_on = [ nomad_job.multimedia ]
  
  timeouts {
    create = "15m"
    update = "15m"
  }
}






