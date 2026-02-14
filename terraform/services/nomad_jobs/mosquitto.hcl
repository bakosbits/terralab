job "mosquitto" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "mosquitto" {

    network {
      port "mqtt" { static = 1883 }
      port "websocket" { static = 9001 }

    }

    volume "mosquitto" {
      type            = "${storage_type}"
      source          = "mosquitto"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "mosquitto-logs" {
      type            = "${storage_type}"
      source          = "mosquitto-logs"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "mosquitto"
      port = "mqtt"

      check {
        type     = "tcp"
        port     = "mqtt"
        interval = "10s"
        timeout  = "2s"
      }
    }

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    task "mosquitto" {
      driver = "docker"

      config {
        image = "eclipse-mosquitto:${version}"
        ports = ["mqtt", "websocket"]
        volumes = [
          "secrets/password.txt:/config/password.txt",
          "local/config/mosquitto.conf:/config/mosquitto.conf"
        ]
      }

      volume_mount {
        volume      = "mosquitto"
        destination = "/data"
      }

      volume_mount {
        volume      = "mosquitto-logs"
        destination = "/logs"
      }


      env {
        PUID = "${uid}"
        PGID = "${gid}"
        TZ   = "${timezone}"
      }

      resources {
        cpu    = 300
        memory = 384
      }


      template {
        destination = "local/config/mosquitto.conf"
        data        = <<-EOF
        {{- key "${lab_name}/mqtt/mosquitto.conf" }}
        EOF
      }


      template {
        destination = "secrets/password.txt"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/mqtt" }}
          {{ .USER }}:{{ .PASSWORD }}
        {{- end }}        
        EOF
      }

    }
  }
}