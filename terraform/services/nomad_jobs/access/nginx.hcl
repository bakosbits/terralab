# No longer used

job "nginx" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "nginx" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

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
        image = "${registry_cache}/linuxserver/nginx:latest"
        ports = ["http"]
        volumes = [
          "/mnt/volumes/nginx/config:/config",
        ]
      }

      env {
        PUID = "${uid}"
        PGID = "${gid}"
        TZ   = "${timezone}"
      }

      resources {
        cpu    = 250
        memory = 512
      }
    }
  }
}