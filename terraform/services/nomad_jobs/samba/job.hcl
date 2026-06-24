job "samba" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "samba" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = "445" }
    }

    service {
      name = "samba"
      port = "http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "samba" {
      driver = "docker"

      config {
        image = "dockurr/samba"
        ports = ["http"]
        volumes = [
          "/mnt/projects:/storage/projects",
          "/mnt/volumes/media:/storage/media"
        ]
      }

      resources {
        cpu    = 100
        memory = 256
      }

      template {
        env         = true
        destination = "secrets/env"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/samba" }}
          {{- range .Tuples }}
            {{ .K }}={{ .V }}
          {{- end }}
        {{- end }}
        EOF
      }
    }
  }
}
