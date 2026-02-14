job "code-server" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "code-server" {

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
        static = 8843
        to     = 8443
      }
    }

    volume "code-server" {
      type            = "${storage_type}"
      source          = "code-server"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "projects" {
      type            = "${storage_type}"
      source          = "projects"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
<<<<<<< HEAD
    
=======

>>>>>>> feature/per-volume-node-targeting
    service {
      name = "code-server"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.code-server.entrypoints=websecure",
      ]

      check {
        type     = "http"
        method   = "GET"
        path     = "/healthz"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "code-server" {
      driver = "docker"

      config {
<<<<<<< HEAD
        image        = "linuxserver/code-server:${version}"
        ports        = ["http"]
=======
        image = "linuxserver/code-server:${version}"
        ports = ["http"]
>>>>>>> feature/per-volume-node-targeting
      }

      volume_mount {
        volume      = "code-server"
        destination = "/config"
      }

      volume_mount {
        volume      = "projects"
        destination = "/home/coder/projects"
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