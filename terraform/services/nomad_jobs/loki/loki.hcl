job "loki" {
  datacenters = ["dc1"]
  type        = "service"

  group "loki" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = 3100 }
    }

    volume "loki" {
      type            = "${storage_type}"
      source          = "loki"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "loki"
      port = "http"
    }

    task "loki" {
      driver = "docker"


      config {
        image = "grafana/loki:main-035b4d2"
        ports = ["http"]
        args  = ["-config.file=/local/loki-config.yaml"]
      }

      volume_mount {
        volume      = "loki"
        destination = "/loki"
      }

      resources {
        cpu    = 500
        memory = 1024
      }
      template {
        destination = "local/loki-config.yaml"
        data        = <<-EOF
          {{- key "${lab_name}/loki/loki.yaml" }}
        EOF
      }
    }
  }
}