job "vaultwarden" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "vaultwarden" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 8089 }
    }

    volume "vaultwarden" {
      type            = "${storage_type}"
      source          = "vaultwarden"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
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
        image = "${registry_cache}/vaultwarden/server:1.31.0"
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
        cpu    = 100
        memory = 256
      }
    }
  }
}