job "jellyfin" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "jellyfin" {

    network {
      port "http" { static = 8096 }
    }

    volume "jellyfin" {
      type            = "csi"
      source          = "jellyfin"
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
      name = "jellyfin"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.jellyfin.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "jellyfin" {
      driver = "docker"

      config {
        image = "linuxserver/jellyfin:10.9.8"
        ports = ["http"]
      }

      volume_mount {
        volume      = "jellyfin"
        destination = "/config/cache"
      }

      volume_mount {
        volume      = "media"
        destination = "/data"
      }

      env {
        PUID                        = ${uid}
        PGID                        = ${gid}
        JELLYFIN_PublishedServerUrl = "https://jellyfin.${domain}"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}