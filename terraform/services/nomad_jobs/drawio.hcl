job "drawio" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "drawio" {

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
        image = "jgraph/drawio:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
