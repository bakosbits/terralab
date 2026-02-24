job "pgweb" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "pgweb" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = 8082 }
    }

    service {
      name = "pgweb"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.pgweb.entrypoints=websecure",
        "traefik.http.routers.pgweb.rule=Host(`pgweb.bakos.me`)",
      ]

      check {
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "pgweb" {
      driver = "docker"

      config {
        image        = "sosedoff/pgweb:0.17.0"
        network_mode = "host"
        ports        = ["http"]
        command      = "/usr/bin/pgweb"
        args         = ["--bind=0.0.0.0", "--listen=8082"]
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}