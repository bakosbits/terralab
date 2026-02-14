locals {
  defaults = {
    lab_name          = "terralab"
    consul_addr       = "http://localhost:8500"
    nomad_addr        = "http://localhost:4646"
    consul_domain     = "service.consul"
    datacenter        = "dc1"
    region            = "global"
    cidr              = "192.168.2.0/24"
    nomad_job_ext     = "hcl"
    storage_type      = "host"
    host_storage_path = "/mnt"
    timezone          = "etc/UTC"
    uid               = 1000
    gid               = 1000
    pve_backup_addr   = var.env.pve_backup_addr
    pfsense_addr      = var.env.pfsense_addr
    virtual_ip        = var.env.virtual_ip
    secret_id         = var.env.secret_id
    pve_addr          = var.env.pve_addr
    domain            = var.env.domain
    dns               = var.env.dns
  }
  vars = merge(local.defaults, var.env)
}


variable "env" {
  type        = any
  default     = {}
  description = "A map of all environment variables"
}

variable "volumes" {
  type = map(object({
    volume_id   = string
    external_id = string
    access_mode = string
    nodes       = optional(list(string))
  }))
  description = "Volumes for cluster services"
}


variable "consul_kv" {
  type = map(object({
    filenames = list(string)
    vars      = optional(map(any), {})
  }))
  description = "Key-Value pairs for Consul's kv store"
}

variable "nomad_jobs" {
  type = map(object({
    jobs = map(any)
  }))
}

variable "nomad_vars" {
  type = map(object({
    vars = map(any)
  }))
}

