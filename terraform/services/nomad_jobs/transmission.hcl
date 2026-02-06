job "transmission" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "transmission" {

    network {
      mode = "host"
      port "http" {
        static = 9091
        to     = 9091
      }
    }

    volume "transmission" {
      type            = "csi"
      source          = "transmission"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    volume "downloads" {
      type            = "csi"
      source          = "downloads"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    volume "torrents" {
      type            = "csi"
      source          = "torrents"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }


    service {
      name = "transmission"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.transmission.entrypoints=websecure",
        "traefik.http.routers.transmission.middlewares=auth@consulcatalog"
      ]

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "transmission" {
      driver = "docker"

      config {
        image = "lscr.io/linuxserver/transmission:4.0.6"
        ports = ["http"]
      }

      volume_mount {
        volume      = "transmission"
        destination = "/config"
      }

      volume_mount {
        volume      = "downloads"
        destination = "/downloads"
      }

      volume_mount {
        volume      = "torrents"
        destination = "/watch"
      }


      env {
        PUID = 1010
        PGID = 1010
        TZ   = "America/Denver"
      }

      resources {
        cpu    = 750
        memory = 756
      }
    }
  }
}