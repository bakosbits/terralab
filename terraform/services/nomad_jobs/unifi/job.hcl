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

    service {
      name = "unifi"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.unifi.entrypoints=websecure",
        "traefik.http.services.unifi.loadbalancer.server.scheme=https",
        "traefik.http.services.unifi.loadbalancer.server.port=$${NOMAD_HOST_PORT_http}",
        "traefik.http.routers.unifi.middlewares=auth",        
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
        image        = "linuxserver/unifi-network-application:10.0.162"
        ports        = ["http"]
        volumes = [
          "/mnt/unifi:/config",
        ]
      }

      resources {
        cpu    = 750
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