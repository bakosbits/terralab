job "grafana" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "grafana" {

    network {
      port "http" { to = 3000 }
    }

    volume "grafana" {
      type            = "csi"
      source          = "grafana"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "grafana"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.grafana.entrypoints=websecure",
        "traefik.http.routers.grafana.rule=Host(`grafana.bakos.me`)",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "grafana" {
      driver = "docker"
      user   = "root"

      config {
        image = "grafana/grafana-oss:11.1.3"
        ports = ["http"]
      }

      volume_mount {
        volume      = "grafana"
        destination = "/var/lib/grafana"
      }

      resources {
        cpu    = 250
        memory = 256
      }

      template {
        destination = "secrets/grafana.env"
        env         = true
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/grafana" }}
          {{- range .Tuples }}
            {{ .K }}={{ .V }}
          {{- end }}
        {{- end }}
        EOF
      }
    }
  }
}