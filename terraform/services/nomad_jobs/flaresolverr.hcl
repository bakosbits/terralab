job "flaresolverr" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "flaresolverr" {

    network {
      port "http" { static = "8191" }
    }

    volume "flaresolverr" {
      type            = "csi"
      source          = "flaresolverr"
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
        image = "flaresolverr/flaresolverr:latest"
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
        cpu    = 500
        memory = 512
      }
    }
  }
}
