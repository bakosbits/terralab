terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.93.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.provider_vars.proxmox_url
  username = var.provider_vars.proxmox_user
  password = var.provider_vars.proxmox_password
  insecure = true
}