job "flaresolverr" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "flaresolverr" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = "8191" }
    }

    volume "flaresolverr" {
      type            = "${storage_type}"
      source          = "flaresolverr"
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
      name = "flaresolverr"
      port = "http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "flaresolverr" {
      driver = "docker"

      config {
        image = "flaresolverr/flaresolverr:v3.4.6"
        ports = ["http"]
      }

      volume_mount {
        volume      = "flaresolverr"
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
