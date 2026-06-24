# This resource reads .nv.yaml files from nomad_jobs/<service>/
# and defines Nomad variables for use in job environments

locals {

  nomad_vars = {
    for job in local.deployed_jobs :
    job => yamldecode(templatefile("${local.jobs}/${job}/nomad_vars.yaml", var.env))
    if fileexists("${local.jobs}/${job}/nomad_vars.yaml")
  }
}

resource "nomad_variable" "secrets" {
  for_each = local.nomad_vars
  path     = "nomad/jobs/${each.key}"
  items    = each.value
}
