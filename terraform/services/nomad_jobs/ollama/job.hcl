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
      port "http" { static = 11434 }
    }

    service {
      name = "ollama"
      port = "http"

      check {
        type     = "http"
        path     = "/api/tags"
        interval = "20s"
        timeout  = "5s"
      }
    }

    task "ollama" {
      driver = "docker"

      config {
        image = "ollama/ollama:latest"
        ports = ["http"]
        volumes = [
          "/mnt/ollama:/root/.ollama",
        ]
      }

      env {
        OLLAMA_KEEP_ALIVE  = "5m"
        OLLAMA_NUM_THREADS = "8"
      }

      resources {
        cpu    = 12000
        memory = 24576
      }
    }
  }
}