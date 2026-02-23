job "sabnzbd" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "sabnzbd" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = "8080" }
    }

    volume "sabnzbd" {
      type            = "${storage_type}"
      source          = "sabnzbd"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "media" {
      type            = "${storage_type}"
      source          = "media"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      port = "http"
      name = "sabnzbd"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.sabnzbd.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "sabnzbd" {
      driver = "docker"

      config {
        image = "linuxserver/sabnzbd:4.3.2"
        ports = ["http"]
      }

      volume_mount {
        volume      = "sabnzbd"
        destination = "/config"
      }

      volume_mount {
        volume      = "media"
        destination = "/data"
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
