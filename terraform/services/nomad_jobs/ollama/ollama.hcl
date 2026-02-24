job "ollama" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "ollama" {

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

    volume "ollama" {
      type            = "${storage_type}"
      source          = "ollama"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "open-webui" {
      type            = "${storage_type}"
      source          = "open-webui"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "open-webui"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.open-webui.entrypoints=websecure",
        "traefik.http.routers.open-webui.rule=Host(`ai.${tld}`)",
      ]

      check {
        type     = "http"
        path     = "/"
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
        cpu    = 10000
        memory = 12288
      }
    }
  }
}