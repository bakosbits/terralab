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
      port "http" { to = 8080}
    }

    volume "privatebin" {
      type            = "${storage_type}"
      source          = "privatebin"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "privatebin"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.privatebin.entrypoints=websecure",
        "traefik.http.routers.privatebin.rule=Host(`bin.${domain}`)",        
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
        image        = "privatebin/fs:${version}"
        ports        = ["http"]
      }

      volume_mount {
        volume      = "privatebin"
        destination = "/config"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}