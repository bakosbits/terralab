job "cyberchef" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "cyberchef" {

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
      name = "cyberchef"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.cyberchef.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "cyberchef" {
      driver = "docker"

      config {
<<<<<<< HEAD
        image        = "ghcr.io/gchq/cyberchef:${version}"
        ports        = ["http"]
=======
        image = "ghcr.io/gchq/cyberchef:${version}"
        ports = ["http"]
>>>>>>> feature/per-volume-node-targeting
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}