# This resource reads .tftpl files from the nomad_vars directory
# and defines Nomad variables for use in job environments

locals {
  nomad_vars_dir = "${path.module}/nomad_vars"

  nomad_vars = {
    for file in fileset(local.nomad_vars_dir, "*.tftpl") :
    trimsuffix(file, ".tftpl") => {
      for line in [
        for l in split("\n", templatefile("${local.nomad_vars_dir}/${file}", local.vars)) :
        l if trimspace(l) != ""
      ] :
      trimspace(split(":", line)[0]) => trimspace(join(":", slice(split(":", line), 1, length(split(":", line)))))
    }
  }
}

resource "nomad_variable" "secrets" {
  for_each = local.nomad_vars
  path     = "nomad/jobs/${each.key}"
  items    = each.value
}
