job "home_assistant" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "home_assistant" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = "8123" }
    }

    volume "hass" {
      type            = "${storage_type}"
      source          = "hass"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "home-assistant"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.home_assistant.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "home_assistant" {
      driver = "docker"

      config {
        image        = "homeassistant/home-assistant:2026.1.2"
        network_mode = "host"
        ports        = ["http"]
        volumes = [
          "local/automations.yaml:/config/automations.yaml",
          "local/binary_sensors.yaml:/config/binary_sensors.yaml",
          "local/configuration.yaml:/config/configuration.yaml",
          "local/covers.yaml:/config/covers.yaml",
          "local/customize.yaml:/config/customize.yaml",
          "local/fans.yaml:/config/fans.yaml",
          "local/lights.yaml:/config/lights.yaml",
          "local/google_assistant.yaml:/config/google_assistant.yaml",
          "local/scripts.yaml:/config/scripts.yaml",
          "local/secrets.yaml:/config/secrets.yaml",
          "local/service_account.json:/config/service_account.json",
          "local/switches.yaml:/config/switches.yaml",
          "local/trusted_proxies.yaml:/config/trusted_proxies.yaml",
        ]
      }

      volume_mount {
        volume      = "hass"
        destination = "/config"
      }

      env {
        TZ = "${timezone}"
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      template {
        destination = "local/automations.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/automations.yaml" }}
        EOF
      }

      template {
        destination = "local/binary_sensors.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/binary_sensors.yaml" }}
        EOF
      }

      template {
        destination = "local/configuration.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/configuration.yaml" }}
        EOF
      }

      template {
        destination = "local/covers.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/covers.yaml" }}
        EOF
      }

      template {
        destination = "local/customize.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/customize.yaml" }}
        EOF
      }

      template {
        destination = "local/fans.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/fans.yaml" }}
        EOF
      }

      template {
        destination = "local/lights.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/lights.yaml" }}
        EOF
      }

      template {
        destination = "local/google_assistant.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/google_assistant.yaml" }}
        EOF
      }

      template {
        destination = "local/scripts.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/scripts.yaml" }}
        EOF
      }

      template {
        destination = "local/secrets.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/secrets.yaml" }}
        EOF
      }

      template {
        destination = "local/service_account.json"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/service_account.json" }}
        EOF
      }

      template {
        destination = "local/switches.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/switches.yaml" }}
        EOF
      }

      template {
        destination = "local/trusted_proxies.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/home_assistant/trusted_proxies.yaml" }}
        EOF
      }
    }
  }
}
