job "sonarr" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "sonarr" {

    network {
      port "http" { to = 8989 }
    }

    volume "sonarr" {
      type            = "csi"
      source          = "sonarr"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    volume "media" {
      type            = "csi"
      source          = "media"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "sonarr"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.sonarr.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/ping"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "sonarr" {
      driver = "docker"

      config {
        image = "linuxserver/sonarr:4.0.14"
        ports = ["http"]
      }

      volume_mount {
        volume      = "sonarr"
        destination = "/config"
      }

      volume_mount {
        volume      = "media"
        destination = "/data"
      }

      env {
        PUID = "${uid}"
        PGID = "${gid}"
        TZ   = "${timezone}"
      }

      resources {
        cpu    = 1000
        memory = 1024
      }
    }
  }
}