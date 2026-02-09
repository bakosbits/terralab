# This resource reads nomad_vars map from nomad_vars.auto.tfvars and 
# defines Nomad variables so they can be used in job environments

resource "nomad_variable" "secrets" {
  for_each = var.nomad_vars
  path     = "nomad/jobs/${each.key}"

  items = {
    for k, v in each.value.vars : k => tostring(v)
  }
}