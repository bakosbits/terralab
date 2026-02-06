job "n8n" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "n8n" {

    network {
      port "http" {
        to = "5678"
      }
    }

    volume "n8n" {
      type            = "csi"
      source          = "n8n"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
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
      }

      volume_mount {
        volume      = "n8n"
        destination = "/home/node/.n8n"
      }

      env {
        PUID                                  = 1000
        PGID                                  = 1000
        N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = true
        N8N_LOG_LEVEL                         = "debug"
        N8N_LOG_OUTPUT                        = "file"
        N8N_SECURE_COOKIE                     = false
        TZ                                    = "America/Denver"
      }


      resources {
        cpu    = 1024
        memory = 1024
      }
    }
  }
}