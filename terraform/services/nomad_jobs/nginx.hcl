# No longer used

job "nginx" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "nginx" {

    network {
      port "http" { to = 80 }
    }

    service {
      name = "nginx"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.nginx.entrypoints=websecure",
      ]

    }

    task "nginx" {
      driver = "docker"

      config {
        image = "linuxserver/nginx:latest"
        ports = ["http"]
        volumes = [
          "/mnt/volumes/nginx/config:/config",
        ]
      }

      env {
        PUID = "1010"
        PGID = "1010"
        TZ   = "Etc/UTC"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}