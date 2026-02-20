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
      port "postgres" { to = "5432" }
    }

    volume "postgres" {
      type            = "${storage_type}"
      source          = "postgres"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "postgres"
      port = "postgres"
      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.postgres.entrypoints=postgres",
        "traefik.tcp.routers.postgres.rule=HostSNI(`*`)",
        "traefik.tcp.services.postgres.loadBalancer.server.port=$${NOMAD_HOST_PORT_postgres}"
      ]

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
        image = "${registry_cache}/library/postgres:18.1"
        ports = ["postgres"]
      }

      volume_mount {
        volume      = "postgres"
        destination = "/var/lib/postgresql"
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
