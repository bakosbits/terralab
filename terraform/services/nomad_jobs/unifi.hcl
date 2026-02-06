job "unifi" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "unifi" {

    network {
      port "http" { static = 8443 }
      # port "unifi-adoption"  { static = 8080 }
      # port "unifi-stun"      { static = 3478 }
      # port "unifi-discovery" { static = 10001 }
      # port "unifi-l2"        { static = 1900 }
    }

    volume "unifi" {
      type            = "csi"
      source          = "unifi"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "unifi"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.unifi.entrypoints=websecure",
        "traefik.http.services.unifi.loadbalancer.server.scheme=https",
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
        image        = "linuxserver/unifi-network-application:${version}"
        ports        = ["http"]
      }

      volume_mount {
        volume      = "unifi"
        destination = "/config"
      }

      resources {
        cpu    = ${cpu}
        memory = ${ram}
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