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

    volume "influxdb" {
      type            = "${storage_type}"
      source          = "influxdb"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "influxdb-config" {
      type            = "${storage_type}"
      source          = "influxdb-config"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "influxdb"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.influxdb.entrypoints=websecure",
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
        image = "influxdb:${version}"
        ports = ["http"]
      }

      volume_mount {
        volume      = "influxdb"
        destination = "/var/lib/influxdb2"
      }

      volume_mount {
        volume      = "influxdb-config"
        destination = "/etc/influxdb2"
      }

      resources {
        cpu    = 500
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
