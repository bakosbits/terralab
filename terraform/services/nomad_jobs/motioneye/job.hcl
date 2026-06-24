job "motioneye" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "motioneye" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = 8765 }
    }

    service {
      name = "motioneye"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.motioneye.entrypoints=websecure",
        "traefik.http.routers.motioneye.middlewares=auth",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "motioneye" {
      driver = "docker"

      config {
        image      = "ccrisan/motioneye:master-amd64"
        hostname   = "motioneye"
        privileged = true
        ports      = ["http"]
        volumes = [
          "/etc/localtime:/etc/localtime:ro",
          "/mnt/motioneye/shared:/shared",
          "/mnt/motioneye/etc:/etc/motioneye"
        ]
      }

      resources {
        cpu    = 250
        memory = 512
      }
    }
  }
}