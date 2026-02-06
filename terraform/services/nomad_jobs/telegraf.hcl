job "telegraf" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "telegraf" {

    network {
      port "http" { to = "9273" }
    }

    task "telegraf" {
      driver = "docker"

      service {
        name = "telegraf"
        port = "http"

        check {
          type     = "tcp"
          interval = "5s"
          timeout  = "2s"
        }
      }

      config {
        image = "telegraf:1.31.2"
        ports = ["http"]
        args = [
          "--config=/local/config.toml",
        ]
      }

      resources {
        cpu    = 125
        memory = 128
      }

      template {
        destination = "local/config.toml"
        env         = false
        data        = <<-EOH
        {{- key "homelab/telegraf/config.toml"}}
        EOH
      }
    }
  }
}
