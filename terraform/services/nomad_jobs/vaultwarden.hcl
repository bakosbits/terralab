job "vaultwarden" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "vaultwarden" {

    network {
      port "http" { to = 8089 }
    }

    volume "vaultwarden" {
      type            = "csi"
      source          = "vaultwarden"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "vaultwarden"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.vaultwarden.entrypoints=websecure",
      ]

      check {
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "vaultwarden" {
      driver = "docker"

      config {
        image = "vaultwarden/server:1.31.0"
        ports = ["http"]
      }

      volume_mount {
        volume      = "vaultwarden"
        destination = "/data"
      }

      env {
        ROCKET_PORT = 8089
      }

      resources {
        cpu    = 250
        memory = 256
      }
    }
  }
}