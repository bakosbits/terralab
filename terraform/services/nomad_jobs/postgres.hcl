job "postgres" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "postgres" {

    network {
      port "postgres" { to = "5432" }
    }

    volume "postgres" {
      type            = "csi"
      source          = "postgres"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
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
        image = "postgres:${version}"
        ports = ["postgres"]
      }

      volume_mount {
        volume      = "postgres"
        destination = "/var/lib/pgsql/data"
      }

      resources {
        cpu    = ${cpu}
        memory = ${ram}
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
