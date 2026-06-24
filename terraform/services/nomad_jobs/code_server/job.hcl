job "code-server" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "code-server" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 8443 }
    }

    service {
      name = "code-server"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.code_server.entrypoints=websecure",
        "traefik.http.routers.code_server.middlewares=auth",
      ]

      check {
        type     = "http"
        method   = "GET"
        path     = "/healthz"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "code-server" {
      driver = "docker"

      config {
        image = "linuxserver/code-server:latest"
        ports = ["http"]
        volumes = [
          "/mnt/code_server:/config",

        ]
      }

      volume_mount {
        volume      = "code_server"
        destination = "/config"
      }

      volume_mount {
        volume      = "projects"
        destination = "/home/coder/projects"
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