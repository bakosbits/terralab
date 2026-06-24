job "open-webui" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "open-webui" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 8080 }
    }

    service {
      name = "open-webui"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.open-webui.entrypoints=websecure",
        "traefik.http.routers.open-webui.middlewares=auth",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "20s"
        timeout  = "5s"
      }
    }

    task "open-webui" {
      driver = "docker"

      config {
        image = "ghcr.io/open-webui/open-webui:main"
        ports = ["http"]
        volumes = [
          "/mnt/open-webui:/app/backend/data",
        ]
      }

      env {
        OLLAMA_BASE_URL = "http://ollama.service.consul:11434"
      }

      resources {
        cpu    = 1000
        memory = 2048
      }
    }
  }
}