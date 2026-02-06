job "emulatorjs" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "emulatorjs" {

    network {
      port "http" {
        to = 80
      }

      port "admin" {
        to = 3000
      }
    }

    volume "arcade_config" {
      type            = "csi"
      source          = "arcade-config"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    volume "arcade-data" {
      type            = "csi"
      source          = "arcade-data"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "arcade"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.arcade.entrypoints=websecure",
        "traefik.http.routers.arcade.rule=Host(`arcade.bakos.me`)",
        "traefik.http.routers.arcade.middlewares=auth@consulcatalog"
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    service {
      name = "arcade-admin"
      port = "admin"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.arcade-admin.entrypoints=websecure",
        "traefik.http.routers.arcade-admin.middlewares=auth@consulcatalog"
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "emulatorjs" {
      driver = "docker"

      config {
        image = "linuxserver/emulatorjs:1.9.2"
        ports = ["http", "admin"]
      }

      volume_mount {
        volume      = "arcade_config"
        destination = "/config"
      }

      volume_mount {
        volume      = "arcade-data"
        destination = "/data"
      }

      env {
        PUID = "1000"
        PGID = "1000"
        TZ   = "America/Denver"
      }

      resources {
        memory_max = 2048
      }
    }
  }
}