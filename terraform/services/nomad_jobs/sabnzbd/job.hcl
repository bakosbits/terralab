job "sabnzbd" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "sabnzbd" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = "8080" }
    }

    service {
      port = "http"
      name = "sabnzbd"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.sabnzbd.entrypoints=websecure",
        "traefik.http.routers.sabnzbd.middlewares=auth",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "sabnzbd" {
      driver = "docker"

      config {
        image = "linuxserver/sabnzbd:4.3.2"
        ports = ["http"]
        volumes = [
          "/mnt/sabnzbd:/config",
          "/mnt/media/downloads:/downloads"
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
