# This resource reads the map defined in nomad_vars.auto.tfvars and 
# defines Nomad variables for use in job environments

resource "nomad_variable" "secrets" {
  for_each = var.nomad_vars
  path     = "nomad/jobs/${each.key}"

  items = {
    for k, v in each.value.vars : k => tostring(v)
  }
}