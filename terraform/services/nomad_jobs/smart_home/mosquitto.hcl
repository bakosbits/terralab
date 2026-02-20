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

    volume "mosquitto-data" {
      type            = "${storage_type}"
      source          = "mosquitto-data"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }


    volume "mosquitto-log" {
      type            = "${storage_type}"
      source          = "mosquitto-log"
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
        image = "${registry_cache}/library/eclipse-mosquitto:2.1.2-alpine"
        ports = ["mqtt", "websocket"]
        volumes = [
          "secrets/password.txt:/mosquitto/config/password.txt",
          "local/mosquitto.conf:/mosquitto/config/mosquitto.conf"
        ]
      }

      volume_mount {
        volume      = "mosquitto"
        destination = "/mosquitto/config"
      }

      volume_mount {
        volume      = "mosquitto-data"
        destination = "/mosquitto/data"
      }

      volume_mount {
        volume      = "mosquitto-log"
        destination = "/mosquitto/log"
      }

      resources {
        cpu    = 150
        memory = 384
      }


      template {
        destination = "local/mosquitto.conf"
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