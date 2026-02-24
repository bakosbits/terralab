job "radarr" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "radarr" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 7878 }
    }

    volume "radarr" {
      type            = "${storage_type}"
      source          = "radarr"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "media-movies" {
      type            = "${storage_type}"
      source          = "media-movies"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "media-downloads" {
      type            = "${storage_type}"
      source          = "media-downloads"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
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
        volume      = "media-movies"
        destination = "/data"
      }

      volume_mount {
        volume      = "media-downloads"
        destination = "/downloads"
      }

      env {
        PUID = "${uid}"
        PGID = "${gid}"
        TZ   = "${timezone}"
      }

      resources {
        cpu    = 1000
        memory = 3096
      }
    }
  }
}