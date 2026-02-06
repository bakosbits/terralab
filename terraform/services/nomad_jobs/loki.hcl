job "loki" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "loki" {

    network {
      port "http" { static = 3100 }
    }


    volume "loki" {
      type            = "csi"
      source          = "loki"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "loki"
      port = "http"

      check {
        port     = "http"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "loki" {
      driver = "docker"
      user   = "root:root"

      config {
        image        = "grafana/loki:2.9.10"
        network_mode = "host"
        ports        = ["http"]
        args = [
          "-config.file",
          "local/loki/local-config.yaml",
        ]
      }

      volume_mount {
        volume      = "loki"
        destination = "/loki"
      }

      resources {
        cpu    = 500
        memory = 512
      }

      template {
        destination = "local/loki/local-config.yaml"
        data        = <<-EOF
        {{- key "homelab/loki/loki.yaml"}}
        EOF
      }
    }
  }
}