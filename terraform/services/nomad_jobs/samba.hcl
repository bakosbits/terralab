job "samba" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "samba" {

    network {
      port "http" { static = "445" }
    }

    volume "media" {
      type            = "csi"
      source          = "media"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
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
      }

      volume_mount {
        volume      = "media"
        destination = "/storage"
      }

      resources {
        cpu    = ${cpu}
        memory = ${ram}
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
