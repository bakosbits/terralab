job "grafana" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "grafana" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = 3000 }
    }

    service {
      name = "grafana"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.grafana.entrypoints=websecure",
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
        volumes = [
          "/mnt/grafana:/var/lib/grafana"
        ]
      }

      resources {
        cpu    = 100
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