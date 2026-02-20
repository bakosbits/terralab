job "prowlarr" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "prowlarr" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 9696 }
    }

    volume "prowlarr" {
      type            = "${storage_type}"
      source          = "prowlarr"
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
        image = "${registry_cache}/linuxserver/prowlarr:2.3.0"
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
        cpu    = 250
        memory = 512
      }
    }
  }
}