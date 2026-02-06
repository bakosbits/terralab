# This resource loads each jobs env job variables into 
# Nomad Variables so they can be read into job environments

resource "nomad_variable" "secrets" {
  for_each = var.env_vars
  path     = "nomad/jobs/${each.key}"
  
  items = {
    for k, v in each.value.vars : k => tostring(v)
  }

}