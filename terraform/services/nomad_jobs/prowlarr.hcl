job "prowlarr" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "prowlarr" {

    network {
      port "http" {
        to = 9696
      }
    }

    volume "prowlarr" {
      type            = "csi"
      source          = "prowlarr"
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
      name = "prowlarr"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.prowlarr.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/ping"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "prowlarr" {
      driver = "docker"

      config {
        image = "linuxserver/prowlarr:2.3.0"
        ports = ["http"]
      }

      volume_mount {
        volume      = "prowlarr"
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