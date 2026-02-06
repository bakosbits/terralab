job "matter" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "matter" {

    network {
      port "websocket" { static = 5580 }

    }

    volume "matter" {
      type            = "csi"
      source          = "matter"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
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
        image = "ghcr.io/home-assistant-libs/python-matter-server:stable"
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