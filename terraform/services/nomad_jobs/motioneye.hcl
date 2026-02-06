job "motioneye" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "motioneye" {

    network {
      port "http" { static = 8765 }
    }

    volume "motioneye-shared" {
      type            = "csi"
      source          = "motioneye-shared"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    volume "motioneye-etc" {
      type            = "csi"
      source          = "motioneye-etc"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
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
        image      = "ccrisan/motioneye:master-amd64"
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
        cpu    = 500
        memory = 512
      }
    }
  }
}