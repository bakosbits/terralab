job "influxdb" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "influxdb" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { to = "8086" }
    }

    service {
      name = "influxdb"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.influxdb.entrypoints=websecure",
        "traefik.http.routers.influxdb.middlewares=auth",
      ]

      check {
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "influxdb" {
      driver = "docker"

      config {
        image = "influxdb:2.7.8-alpine"
        ports = ["http"]
        volumes = [
          "/mnt/influxdb:/var/lib/influxdb2",
          "/mnt/influxdb/config:/etc/influxdb2"
        ]
      }

      resources {
        cpu    = 250
        memory = 512
      }

      template {
        env         = true
        destination = "secrets/.env"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/influxdb" }}
          {{- range .Tuples }}
            {{ .K }}={{ .V }}
          {{- end }}
        {{- end }}        
        EOF
      }
    }
  }
}
