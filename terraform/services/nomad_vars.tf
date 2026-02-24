# This resource reads .nv.yaml files from nomad_jobs/<service>/
# and defines Nomad variables for use in job environments

locals {
  nomad_vars = {
    for job in local.deployed_jobs :
    job => {
      for line in [
        for l in split("\n", templatefile("${local.jobs}/${job}/${job}.nv.yaml", local.vars)) :
        l if trimspace(l) != ""
      ] :
      trimspace(split(":", line)[0]) => trimspace(join(":", slice(split(":", line), 1, length(split(":", line)))))
    }
    if fileexists("${local.jobs}/${job}/${job}.nv.yaml")
  }
}

resource "nomad_variable" "secrets" {
  for_each = local.nomad_vars
  path     = "nomad/jobs/${each.key}"
  items    = each.value
}
