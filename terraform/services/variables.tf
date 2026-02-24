locals {
  defaults = {
    lab_name     = "homelab"
    consul_tld   = "service.consul"
    datacenter   = "dc1"
    timezone     = "Etc/UTC"
    uid          = 1000
    gid          = 1000
    storage_type = "host"
    mount_point  = "/mnt"
  }
  vars = merge(local.defaults, var.env)
}

variable "env" {
  description = "A map of all environment variables"
  type        = any
  default     = {}
}

variable "nomad_jobs" {
  type = map(object({
    jobs = list(string)
  }))
  description = "A map of nomad jobs in deployment order"
}
