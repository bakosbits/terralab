job "plex" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "plex" {

    update {
      canary       = 1 
      auto_promote = true 
      auto_revert  = true 
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }  
    
    network {
      port "http" { static = 32400 }
    }

    volume "plex" {
      type            = "${storage_mode}"
      source          = "plex"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "media" {
      type            = "${storage_mode}"
      source          = "media"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "plex"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.plex.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/web"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "plex" {
      driver = "docker"

      config {
        image        = "plexinc/pms-docker:latest"
        network_mode = "host"
        ports        = ["http"]
      }

      volume_mount {
        volume      = "plex"
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
        cpu    = 1000
        memory = 1024
      }
    }
  }
}