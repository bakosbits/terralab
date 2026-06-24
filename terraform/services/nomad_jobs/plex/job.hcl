job "plex" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "plex" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = 32400 }
    }

    service {
      name = "plex"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.plex.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/web"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "plex" {
      driver = "docker"

      config {
        image        = "plexinc/pms-docker:latest"
        network_mode = "host"
        volumes = [
          "/mnt/plex:/config",
          "/mnt/media:/data"
        ]
      }

      env {
        PUID       = "${uid}"
        PGID       = "${gid}"
        TZ         = "${timezone}"
        PLEX_CLAIM = "claim-3V7PeghtJs9F2159NeEe"
      }

      resources {
        cpu    = 512
        memory = 1024
      }
    }
  }
}