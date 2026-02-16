locals {
  nomad = {
    address   = var.env.nomad_addr
    secret_id = var.env.secret_id
  }

  consul = {
    address = var.env.consul_addr
  }

  job_templates = {
    datacenter    = var.env.datacenter
    region        = var.env.region
    consul_domain = var.env.consul_domain
    domain        = var.env.domain
  }

  kv_templates = {
    domain          = var.env.domain
    nomad_addr      = var.env.nomad_addr
    consul_addr     = var.env.consul_addr
    pfsense_addr    = var.env.pfsense_addr
    pve_addr        = var.env.pve_addr
    pve_backup_addr = var.env.pve_backup_addr
  }
}