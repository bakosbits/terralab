terraform {
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "2.22.1"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.5.2"
    }
  }
}

provider "nomad" {
  address   = var.global.nomad_url
  secret_id = var.global.secret_id
}

provider "consul" {
  address = var.global.consul_url
}

