job "jellyfin" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "jellyfin" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = 8096 }
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
        image = "linuxserver/jellyfin:10.11.6"
        ports = ["http"]
        volumes = [
          "/mnt/jellyfin:/config",
          "/mnt/media:/data"
        ]
      }

      env {
        PUID                        = "${uid}"
        PGID                        = "${gid}"
        TZ                          = "${timezone}"
        JELLYFIN_PublishedServerUrl = "https://jellyfin.${tld}"
      }

      resources {
        cpu    = 250
        memory = 512
      }
    }
  }
}