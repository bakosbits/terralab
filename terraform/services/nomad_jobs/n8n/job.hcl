job "n8n" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "n8n" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = "5678" }
    }

    service {
      name = "n8n"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.n8n.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "n8n" {
      driver = "docker"

      config {
        image = "docker.n8n.io/n8nio/n8n:latest"
        ports = ["http"]
        volumes = [
          "/mnt/n8n:/home/node/.n8n"
        ]
      }

      env {
        PUID                                  = "${uid}"
        PGID                                  = "${gid}"
        N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = true
        N8N_LOG_LEVEL                         = "debug"
        N8N_LOG_OUTPUT                        = "file"
        N8N_SECURE_COOKIE                     = false
        TZ                                    = "${timezone}"
      }


      resources {
        cpu    = 500
        memory = 1024
      }
    }
  }
}