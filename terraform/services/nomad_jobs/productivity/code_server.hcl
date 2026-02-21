job "code_server" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "code_server" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 8443 }
    }

    volume "code_server" {
      type            = "${storage_type}"
      source          = "code-_erver"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "projects" {
      type            = "${storage_type}"
      source          = "projects"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
    
    service {
      name = "code_server"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.code_server.entrypoints=websecure",
      ]

      check {
        type     = "http"
        method   = "GET"
        path     = "/healthz"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "code_server" {
      driver = "docker"

      config {
        image = "${registry_cache}/linuxserver/code-server:latest"
        ports = ["http"]
      }

      volume_mount {
        volume      = "code_server"
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
        cpu    = 500
        memory = 1024
      }
    }
  }
}