job "wikijs" {
  datacenters = ["${datacenter}"]

  group "wikijs" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 3000 }
    }

    volume "wikijs" {
      type            = "${storage_type}"
      source          = "wikijs"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "wikijs"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.wikijs.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "wikijs" {
      driver = "docker"

      config {
        image = "linuxserver/wikijs:2.5.303"
        ports = ["http"]
      }

      volume_mount {
        volume      = "wikijs"
        destination = "/config"
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