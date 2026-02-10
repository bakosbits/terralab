job "cloudflared" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "cloudflared" {
    count = 1

    update {
      canary       = 1 
      auto_promote = true 
      auto_revert  = true 
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }  

    service {
      name = "cloudflared"
    }

    task "cloudflared" {
      driver = "docker"

      config {
        image        = "cloudflare/cloudflared:latest"
        network_mode = "host"
        args = [
          "tunnel",
          "--no-autoupdate",
          "run",
          "--token",
          "$${CLOUDFLARED_TUNNEL_TOKEN}"
        ]
      }

      resources {
        cpu    = 100
        memory = 128
      }

      template {
        env         = true
        destination = "secrets/cloudflared.env"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/cloudflared" }}
          {{- range .Tuples -}}
            {{ .K }}={{ .V }}
          {{- end -}}
        {{- end -}}
        EOF
      }

    }
  }
}