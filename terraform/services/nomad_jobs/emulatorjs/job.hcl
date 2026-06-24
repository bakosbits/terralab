job "emulatorjs" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "emulatorjs" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" {
        to = 80
      }

      port "admin" {
        to = 3000
      }
    }

    service {
      name = "arcade"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.arcade.entrypoints=websecure",
        "traefik.http.routers.arcade.rule=Host(`arcade.${tld}`)",
        "traefik.http.routers.arcade.middlewares=auth"
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    service {
      name = "arcade-admin"
      port = "admin"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.arcade-admin.entrypoints=websecure",
        "traefik.http.routers.arcade-admin.middlewares=auth"
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "emulatorjs" {
      driver = "docker"

      config {
        image = "linuxserver/emulatorjs:1.9.2"
        ports = ["http", "admin"]
        volumes = [
          "/mnt/emulatorjs/config:/config",
          "/mnt/emulatorjs/data:/data"
        ]
      }

      env {
        PUID = "1000"
        PGID = "1000"
        TZ   = "America/Denver"
      }

      resources {
        memory_max = 2048
      }
    }
  }
}