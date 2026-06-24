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

    service {
      name = "transmission"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.transmission.entrypoints=websecure",
        "traefik.http.routers.transmission.middlewares=auth"
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
        image = "linuxserver/transmission:4.1.0"
        ports = ["http"]
        volumes = [
          "/mnt/transmission:/config",
          "/mnt/media/downloads:/downloads"
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