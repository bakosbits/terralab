variable "global" {
  type        = map(any)
  description = "Global variables, used across the deployment"
}

variable "volumes" {
  type = map(object({
    volume_id   = string
    external_id = string
    access_mode = string
  }))
  description = "Volumes for cluster services"
}

variable "env_vars" {
  type = map(object({
    vars = map(any)
  }))
  description = "Key-Value pairs for Nomad's Variable store"
}

variable "core_services" {
  type = map(object({
    vars = map(any)
  }))
  description = "Template variables for core_services jobs"
}

variable "data_services" {
  type = map(object({
    vars = map(any)
  }))
  description = "Template variables for data_services jobs"
}

variable "cluster_services" {
  type = map(object({
    vars = map(any)
  }))
  description = "Template variables for cluster_services jobs"
}
