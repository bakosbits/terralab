terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.93.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.env.provider.url
  username = var.env.provider.user
  password = var.env.provider.password
  insecure = true
}