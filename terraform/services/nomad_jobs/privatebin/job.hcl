job "privatebin" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "privatebin" {

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
      name = "privatebin"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.privatebin.entrypoints=websecure",
        "traefik.http.routers.privatebin.rule=Host(`bin.${tld}`)",
        "traefik.http.routers.privatebin.middlewares=auth",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "privatebin" {
      driver = "docker"

      config {
        image = "privatebin/fs:edge"
        ports = ["http"]
        volumes = [
          "/mnt/privatebin:/config"
        ]
      }

      resources {
        cpu    = 250
        memory = 512
      }
    }
  }
}