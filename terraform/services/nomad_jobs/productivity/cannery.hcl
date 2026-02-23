job "cannery" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "cannery" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = "4000" }
    }

    service {
      name = "cannery"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.cannery.entrypoints=websecure",
        "traefik.http.routers.cannery.middlewares=auth"
      ]

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "cannery" {
      driver = "docker"

      config {
        image = "shibaobun/cannery:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 250
        memory = 512
      }

      template {
        env         = true
        destination = "secrets/env"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/cannery" }}
          {{- range .Tuples }}
            {{ .K }}={{ .V }}
          {{- end }}
        {{- end }}
        EOF        
      }
    }
  }
}
