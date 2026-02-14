job "matter" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "matter" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "websocket" { static = 5580 }

    }

    volume "matter" {
      type            = "${storage_type}"
      source          = "matter"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "matter"
      port = "websocket"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.matter.entrypoints=websecure",
      ]

      check {
        type     = "tcp"
        port     = "websocket"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "matter" {
      driver = "docker"

      config {
        image = "ghcr.io/home-assistant-libs/python-matter-server:${version}"
        ports = ["websocket"]
      }

      volume_mount {
        volume      = "matter"
        destination = "/data"
      }

      resources {
        cpu    = 300
        memory = 384
      }
    }
  }
}