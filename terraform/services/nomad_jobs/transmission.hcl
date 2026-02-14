job "transmission" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "transmission" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      mode = "host"
      port "http" {
        static = 9091
        to     = 9091
      }
    }

    volume "transmission" {
      type            = "${storage_type}"
      source          = "transmission"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "downloads" {
      type            = "${storage_type}"
      source          = "downloads"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "transmission"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.transmission.entrypoints=websecure",
        "traefik.http.routers.transmission.middlewares=auth@consulcatalog"
      ]

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "transmission" {
      driver = "docker"

      config {
        image = "lscr.io/linuxserver/transmission:${version}"
        ports = ["http"]
      }

      volume_mount {
        volume      = "transmission"
        destination = "/config"
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
        cpu    = 750
        memory = 756
      }
    }
  }
}