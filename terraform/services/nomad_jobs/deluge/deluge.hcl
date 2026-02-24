job "deluge" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "deluge" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" {
        static = 8112
        to     = 8112
      }
      port "8881" {
        static = 8881
        to     = 8881
      }
    }

    volume "deluge" {
      type            = "${storage_type}"
      source          = "deluge"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "downloads" {
      type            = "${storage_type}"
      source          = "downloads"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "deluge"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.deluge.entrypoints=websecure",
        "traefik.http.routers.deluge.middlewares=auth"
      ]

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "deluge" {
      driver = "docker"

      config {
        image = "linuxserver/deluge:latest"
        ports = ["http"]
      }

      volume_mount {
        volume      = "deluge"
        destination = "/config"
      }

      volume_mount {
        volume      = "downloads"
        destination = "/downloads"
      }

      env {
        PUID = "${uid}"
        PGID = "${gid}"
        TZ   = "${timezone}"
      }

      resources {
        cpu    = 375
        memory = 756
      }
    }
  }
}