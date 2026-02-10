job "jellyfin" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "jellyfin" {

    update {
      canary       = 1 
      auto_promote = true 
      auto_revert  = true 
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }  
    
    network {
      port "http" { static = 8096 }
    }

    volume "jellyfin" {
      type            = "${storage_mode}"
      source          = "jellyfin"
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
      name = "jellyfin"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.jellyfin.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "jellyfin" {
      driver = "docker"

      config {
        image = "linuxserver/jellyfin:10.9.8"
        ports = ["http"]
      }

      volume_mount {
        volume      = "jellyfin"
        destination = "/config/cache"
      }

      volume_mount {
        volume      = "media"
        destination = "/data"
      }

      env {
        PUID                        = parseint("${uid}", 10)
        PGID                        = parseint("${gid}", 10)
        TZ                          = "${timezone}"
        JELLYFIN_PublishedServerUrl = "https://jellyfin.${domain}"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}