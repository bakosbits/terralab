job "ollama" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "ai" {

    network {
      port "http" { to = 8080 }
    }

    volume "ollama" {
      type            = "${storage_mode}"
      source          = "ollama"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "open-webui" {
      type            = "${storage_mode}"
      source          = "open-webui"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
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
      }

      volume_mount {
        volume      = "ollama"
        destination = "/root/.ollama"
      }

      volume_mount {
        volume      = "open-webui"
        destination = "/app/backend/data"
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