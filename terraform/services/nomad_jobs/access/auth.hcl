job "auth" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "auth" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = "4181" }
    }

    service {
      name = "auth"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.auth.rule.Host(`auth.${domain}`)",     
        "traefik.http.routers.auth.entrypoints=websecure",
        "traefik.http.middlewares.auth.forwardauth.address=http://auth.${consul_domain}:4181/",
        "traefik.http.middlewares.auth.forwardauth.trustForwardHeader=true",
        "traefik.http.middlewares.auth.forwardauth.authResponseHeaders=X-Forwarded-User X-Forwarded-email",
        "traefik.http.routers.auth.middlewares=auth",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "auth" {
      driver = "docker"

      config {
        image = "${registry_cache}/thomseddon/traefik-forward-auth:2.2.0"
        ports = ["http"]
      }

      template {
        env         = true
        destination = "secrets/auth.env"
        data        = <<-EOF
          {{- with nomadVar "nomad/jobs/auth" }}
            {{- range .Tuples }}
              {{ .K }}={{ .V }}
            {{- end }}
          {{- end }}
        EOF
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}