job "unifi" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "unifi" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = 8443 }
    }

    volume "unifi" {
      type            = "${storage_type}"
      source          = "unifi"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "unifi"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.unifi.entrypoints=websecure",
        "traefik.http.services.unifi.loadbalancer.server.scheme=https",
      ]

      check {
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "unifi" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "linuxserver/unifi-network-application:${version}"
        ports        = ["http"]
      }

      volume_mount {
        volume      = "unifi"
        destination = "/config"
      }

      resources {
        cpu    = 1000
        memory = 1536
      }

      template {
        env         = true
        destination = "secrets/unifi.env"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/unifi" }}
          {{- range .Tuples }}
            {{ .K }}={{ .V }}
          {{- end }}
        {{- end }}
        EOF
      }
    }
  }
}