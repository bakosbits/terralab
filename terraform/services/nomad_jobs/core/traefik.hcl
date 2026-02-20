job "traefik" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "traefik" {

    update {
      max_parallel      = 1
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
      auto_revert       = true
    }

    network {
      port "http" { static = "80" }
      port "https" { static = "443" }
    }

    volume "certs" {
      type            = "${storage_type}"
      source          = "certs"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "traefik-logs" {
      type            = "${storage_type}"
      source          = "traefik-logs"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "traefik"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.api.entrypoints=websecure",
        "traefik.http.routers.api.service=api@internal",
        "traefik.http.services.dummy.loadbalancer.server.port=9000",
        "traefik.http.routers.api.middlewares=auth",
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
        image        = "traefik:3.6.6"
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

      resources {
        cpu    = 250
        memory = 512
      }

      template {
        destination = "local/traefik.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/traefik/traefik.yaml" }}
        EOF
      }

      template {
        destination = "local/dynamic.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/traefik/dynamic.yaml" }}
        EOF
      }
    }
  }
}