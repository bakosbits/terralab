job "radarr" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "radarr" {

    network {
      port "http" { to = 7878 }
    }

    volume "radarr" {
      type            = "csi"
      source          = "radarr"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    volume "media" {
      type            = "csi"
      source          = "media"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    volume "downloads" {
      type            = "csi"
      source          = "downloads"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "radarr"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.radarr.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/ping"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "radarr" {
      driver = "docker"

      config {
        image = "linuxserver/radarr:6.0.4"
        ports = ["http"]
      }

      volume_mount {
        volume      = "radarr"
        destination = "/config"
      }

      volume_mount {
        volume      = "media"
        destination = "/data"
      }

      volume_mount {
        volume      = "downloads"
        destination = "/downloads"
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