job "hass" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "hass" {

    network {
      port "http" { static = "8123" }
    }

    volume "hass" {
      type            = "csi"
      source          = "hass"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "hass"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.hass.entrypoints=websecure",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "hass" {
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
        TZ = "America/Denver"
      }

      resources {
        cpu    = 1000
        memory = 1024
      }

      template {
        destination = "local/automations.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/automations.yaml" }}
        EOF
      }

      template {
        destination = "local/binary_sensors.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/binary_sensors.yaml" }}
        EOF
      }

      template {
        destination = "local/configuration.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/configuration.yaml" }}
        EOF
      }

      template {
        destination = "local/covers.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/covers.yaml" }}
        EOF
      }

      template {
        destination = "local/customize.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/customize.yaml" }}
        EOF
      }

      template {
        destination = "local/fans.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/fans.yaml" }}
        EOF
      }

      template {
        destination = "local/lights.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/lights.yaml" }}
        EOF
      }

      template {
        destination = "local/google_assistant.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/google_assistant.yaml" }}
        EOF
      }

      template {
        destination = "local/scripts.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/scripts.yaml" }}
        EOF
      }

      template {
        destination = "local/secrets.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/secrets.yaml" }}
        EOF
      }

      template {
        destination = "local/service_account.json"
        data        = <<-EOF
        {{- key "homelab/hass/service_account.json" }}
        EOF
      }

      template {
        destination = "local/switches.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/switches.yaml" }}
        EOF
      }

      template {
        destination = "local/trusted_proxies.yaml"
        data        = <<-EOF
        {{- key "homelab/hass/trusted_proxies.yaml" }}
        EOF
      }
    }
  }
}
