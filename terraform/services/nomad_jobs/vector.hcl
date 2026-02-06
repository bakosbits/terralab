job "vector" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "vector" {

    network {
      port "api" { static = 8686 }
    }

    service {
      name = "vector"
      port = "api"

      check {
        type     = "tcp"
        port     = "api"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "vector" {
      driver = "docker"

      config {
        image        = "timberio/vector:0.41.X-debian"
        network_mode = "host"
        ports        = ["api"]
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro",
        ]
      }

      kill_timeout = "30s"

      env {
        VECTOR_CONFIG          = "local/vector.toml"
        VECTOR_REQUIRE_HEALTHY = "false"
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      template {
        destination   = "local/vector.toml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        data          = <<-EOF
        {{- key "homelab/vector/vector.toml"}}
        EOF
      }

    }
  }
}