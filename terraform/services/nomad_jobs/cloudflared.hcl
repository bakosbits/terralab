job "cloudflared" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "cloudflared" {
    count = 1


    service {
      name = "cloudflared"
    }

    task "cloudflared" {
      driver = "docker"

      config {
        image        = "cloudflare/cloudflared:${version}"
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
        cpu    = ${cpu}
        memory = ${ram}
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