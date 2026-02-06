job "ollama" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "ai" {

    network {
      port "http" { to = 8080 }
    }

    service {
      name = "ollama"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.open-webui.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/health"
        interval = "20s"
        timeout  = "5s"
      }
    }

    task "ollama" {
      driver = "docker"

      config {
        image = "ghcr.io/open-webui/open-webui:ollama"
        ports = ["http"]
        volumes = [
          "/mnt/volumes/open-webui:/app/backend/data",
          "/mnt/volumes/ollama:/root/.ollama"
        ]
      }

      # CPU-Only Optimization
      env {
        OLLAMA_KEEP_ALIVE  = "5m"
        OLLAMA_NUM_THREADS = "8"
      }

      resources {
        cpu    = 10240
        memory = 32768
      }
    }
  }
}