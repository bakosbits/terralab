job "gitea" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "gitea" {

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
        static = 3000
        to     = 3000
      }
      port "ssh" {
        static = 222
        to     = 22
      }
    }

    service {
      name = "gitea"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.gitea.entrypoints=websecure",
        "traefik.http.routers.gitea.middlewares=auth",
      ]

      check {
        type     = "http"
        path     = "/api/healthz"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "gitea" {
      driver = "docker"

      config {
        image = "gitea/gitea:1.25.4"
        ports = ["http"]
        volumes = [
          "/mnt/gitea:/data"
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