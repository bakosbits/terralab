job "hass" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "hass" {

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

    service {
      name = "hass"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.hass.entrypoints=websecure"
      ]

      check {
        type     = "http"
        path     = "/manifest.json"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "hass" {
      driver = "docker"

      config {
        image        = "homeassistant/home-assistant:2026.11.1"
        network_mode = "host"
        privileged   = true
        volumes = [
          "local/automations.yaml:/config/automations.yaml",
          "local/configuration.yaml:/config/configuration.yaml",
          "local/customize.yaml:/config/customize.yaml",
          "local/google_assistant.yaml:/config/google_assistant.yaml",
          "local/media_players.yaml:/config/media_players.yaml",          
          "local/secrets.yaml:/config/secrets.yaml",
          "local/scripts.yaml:/config/scripts.yaml",
          "local/service_account.json:/config/service_account.json",
          "/mnt/hass:/config"
        ]
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
        {{- key "${lab_name}/hass/automations.yaml" }}
        EOF
      }

      template {
        destination = "local/configuration.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/hass/configuration.yaml" }}
        EOF
      }

      template {
        destination = "local/customize.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/hass/customize.yaml" }}
        EOF
      }

      template {
        destination = "local/google_assistant.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/hass/google_assistant.yaml" }}
        EOF
      }

      template {
        destination = "local/media_players.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/hass/media_players.yaml" }}
        EOF
      }

      template {
        destination = "local/scripts.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/hass/scripts.yaml" }}
        EOF
      }

      template {
        destination = "local/secrets.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/hass/secrets.yaml" }}
        EOF
      }

      template {
        destination = "local/service_account.json"
        data        = <<-EOF
        {{- key "${lab_name}/hass/service_account.json" }}
        EOF
      }

    }
  }
}
