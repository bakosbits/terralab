job "motioneye" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "motioneye" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = 8765 }
    }

    volume "motioneye-shared" {
      type            = "${storage_type}"
      source          = "motioneye-shared"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "motioneye-etc" {
      type            = "${storage_type}"
      source          = "motioneye-etc"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "motioneye"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.motioneye.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "motioneye" {
      driver = "docker"

      config {
        image      = "${registry_cache}/ccrisan/motioneye:master-amd64"
        hostname   = "motioneye"
        privileged = true
        ports      = ["http"]
        volumes = [
          "/etc/localtime:/etc/localtime:ro",
        ]
      }

      volume_mount {
        volume      = "motioneye-shared"
        destination = "/shared"
      }

      volume_mount {
        volume      = "motioneye-etc"
        destination = "/etc/motioneye"
      }

      resources {
        cpu    = 250
        memory = 512
      }
    }
  }
}