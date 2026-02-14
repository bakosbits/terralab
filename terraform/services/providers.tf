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
  address   = var.env.nomad_addr
  secret_id = var.env.secret_id
}

provider "consul" {
  address = var.env.consul_addr
}

