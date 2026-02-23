locals {
  defaults = {
    lab_name   = "homelab"
    consul_tld = "service.consul"
    datacenter = "dc1"
    timezone   = "Etc/UTC"
    uid        = 1000
    gid        = 1000
  }
  vars = merge(local.defaults, var.env)
}

variable "env" {
  description = "A map of all environment variables"
  type        = any
  default     = {}
}

variable "storage" {
  type = object({
    type        = string
    mount_point = string
    nfs_server  = string
    volumes = map(object({
      volume_id   = string
      external_id = string
      access_mode = string
      # Wrap the type in optional()
      nodes = optional(list(string))
    }))
  })
  description = "Configuration for host storage and volume mapping"
}

variable "nomad_jobs" {
  type = map(object({
    jobs = list(string)
  }))
  description = "A map of nomad jobs in deployment order"
}
