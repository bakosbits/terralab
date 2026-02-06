job "sabnzbd" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "sabnzbd" {

    network {
      port "http" { to = "8080" }
    }

    volume "sabnzbd" {
      type            = "csi"
      source          = "sabnzbd"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    volume "media" {
      type            = "csi"
      source          = "media"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
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
        cpu    = 500
        memory = 512
      }
    }
  }
}
