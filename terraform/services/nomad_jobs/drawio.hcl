job "drawio" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "drawio" {

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
      name = "drawio"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.drawio.entrypoints=websecure",
        "traefik.http.routers.drawio.middlewares=auth@consulcatalog"
      ]

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "drawio" {
      driver = "docker"

      config {
        image = "jgraph/drawio:${version}"
        ports = ["http"]
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
