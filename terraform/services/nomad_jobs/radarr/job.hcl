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

    service {
      name = "radarr"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.radarr.entrypoints=websecure",
        "traefik.http.routers.radarr.middlewares=auth",
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
        volumes = [
          "/mnt/radarr:/config",
          "/mnt/media/movies:/data",
          "/mnt/media/downloads:/downloads"
        ]
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