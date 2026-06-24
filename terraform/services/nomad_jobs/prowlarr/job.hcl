job "prowlarr" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "prowlarr" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 9696 }
    }

    service {
      name = "prowlarr"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.prowlarr.entrypoints=websecure",
        "traefik.http.routers.prowlarr.middlewares=auth",
      ]

      check {
        type     = "http"
        path     = "/ping"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "prowlarr" {
      driver = "docker"

      config {
        image = "linuxserver/prowlarr:2.3.0"
        ports = ["http"]
        volumes = [
          "/mnt/prowlarr:/config",
          "/mnt/media:/data"
        ]
      }

      env {
        PUID = "${uid}"
        PGID = "${gid}"
        TZ   = "${timezone}"
      }

      resources {
        cpu    = 250
        memory = 512
      }
    }
  }
}