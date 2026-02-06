# These resources merge global vars (if-used) with job-specific 
# variables and render the job templates with everything combined.

locals {
  jobs = "${path.module}/nomad_jobs"
}

resource "nomad_job" "core_services" {
  for_each = var.core_services

  jobspec = templatefile("${local.jobs}/${each.key}.hcl", 
    merge(
      var.global,        # The global var map
      each.value.vars    # The job-specific var map
    )
  )
  detach = false
  depends_on = [nomad_variable.secrets]
}

resource "nomad_job" "data_services" {
  for_each = var.data_services

  jobspec = templatefile("${local.jobs}/${each.key}.hcl", 
    merge(
      var.global,        # The global var map
      each.value.vars    # The job-specific var map
    )
  )
  detach = false
  depends_on = [nomad_job.core_services]
}


resource "nomad_job" "cluster_services" {
  for_each = var.cluster_services

  jobspec = templatefile("${local.jobs}/${each.key}.hcl", 
    merge(
      var.global,        # The global var map
      each.value.vars    # The job-specific var map
    )    
  )
  detach = false
  depends_on = [nomad_job.data_services]
}

