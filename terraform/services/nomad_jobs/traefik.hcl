job "traefik" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "traefik" {

    network {
      port "http" { static = "80" }
      port "https" { static = "443" }
    }

    volume "certs" {
      type            = "csi"
      source          = "certs"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    volume "traefik-logs" {
      type            = "csi"
      source          = "traefik-logs"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "traefik"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.api.entrypoints=websecure",
        "traefik.http.routers.api.service=api@internal",
        "traefik.http.routers.api.rule=Host(`traefik.bakos.me`)",
        "traefik.http.services.dummy.loadbalancer.server.port=9000",
        "traefik.http.routers.api.middlewares=auth@consulcatalog",
      ]

      check {
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:${version}"
        ports        = ["http", "https"]
        network_mode = "host"
        volumes = [
          "local/traefik.yaml:/etc/traefik/traefik.yaml",
          "local/dynamic.yaml:/etc/traefik/dynamic/dynamic.yaml",
        ]
      }

      volume_mount {
        volume      = "certs"
        destination = "/etc/traefik/certs"
      }

      volume_mount {
        volume      = "traefik-logs"
        destination = "/etc/traefik/logs"
      }

      resources {
        cpu    = ${cpu}
        memory = ${ram}
      }

      template {
        destination = "local/traefik.yaml"
        data        = <<-EOF
        {{- key "homelab/traefik/traefik.yaml" }}
        EOF
      }

      template {
        destination = "local/dynamic.yaml"
        data        = <<-EOF
        {{- key "homelab/traefik/dynamic.yaml" }}
        EOF
      }
    }
  }
}