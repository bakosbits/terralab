job "postgres" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "postgres" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "postgres" { static = "5432" }
    }

    service {
      name = "postgres"
      port = "postgres"

      check {
        type     = "tcp"
        port     = "postgres"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "postgres" {
      driver = "docker"

      config {
        image = "postgres:18.1"
        ports = ["postgres"]
        volumes = [
          "/mnt/postgres:/var/lib/postgresql"
        ]
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      template {
        env         = true
        destination = "secrets/postgres.env"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/postgres" }}
          {{- range .Tuples }}
            {{ .K }}={{ .V }}
          {{- end }}
        {{- end }}
        EOF
      }
    }
  }
}
