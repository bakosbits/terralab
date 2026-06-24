job "wikijs" {
  datacenters = ["${datacenter}"]

  group "wikijs" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 3000 }
    }

    service {
      name = "wikijs"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.wikijs.entrypoints=websecure",
        "traefik.http.routers.wikijs.middlewares=auth",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "wikijs" {
      driver = "docker"

      config {
        image = "linuxserver/wikijs:2.5.303"
        ports = ["http"]
        volumes = [
          "/mnt/wikijs:/config"
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