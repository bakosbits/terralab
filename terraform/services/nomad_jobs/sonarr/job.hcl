job "sonarr" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "sonarr" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 8989 }
    }

    service {
      name = "sonarr"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.sonarr.entrypoints=websecure",
        "traefik.http.routers.sonarr.middlewares=auth",
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
        volumes = [
          "/mnt/sonarr:/config",
          "/mnt/media:/data"
        ]
      }

      env {
        PUID = "${uid}"
        PGID = "${gid}"
        TZ   = "${timezone}"
      }

      resources {
        cpu    = 500
        memory = 1024
      }
    }
  }
}