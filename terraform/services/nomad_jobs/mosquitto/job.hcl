job "mosquitto" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "mosquitto" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "mqtt" { static = 1883 }
      port "websocket" { static = 9001 }

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

    task "mosquitto" {
      driver = "docker"

      config {
        image = "eclipse-mosquitto:alpine"
        ports = ["mqtt", "websocket"]
        volumes = [
          "secrets/password.txt:/mosquitto/config/password.txt",
          "local/mosquitto.conf:/mosquitto/config/mosquitto.conf",
          "/mnt/mosquitto/config:/mosquitto/config",
          "/mnt/mosquitto/data:/mosquitto/data",
          "/mnt/mosquitto/log:/mosquitto/log",
        ]
      }

      resources {
        cpu    = 150
        memory = 384
      }


      template {
        destination = "local/mosquitto.conf"
        data        = <<-EOF
        {{- key "${lab_name}/mosquitto/mosquitto.conf" }}
        EOF
      }


      template {
        destination = "secrets/password.txt"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/mosquitto" }}
          {{ .USER }}:{{ .PASSWORD }}
        {{- end }}        
        EOF
      }

    }
  }
}