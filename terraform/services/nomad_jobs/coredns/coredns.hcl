job "coredns" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "coredns" {

    update {
      max_parallel      = 1
      min_healthy_time  = "10s" # 30s is long for a DNS service
      healthy_deadline  = "5m"
      progress_deadline = "10m"
      auto_revert       = true
    }

    network {
      mode = "host"
      port "dns" { static = 53 }
    }

    task "coredns" {
      driver = "docker"

      config {
        image        = "coredns/coredns:1.11.1"
        network_mode = "host"
        args         = ["-conf", "/etc/coredns/Corefile"]
        volumes = [
          "local/Corefile:/etc/coredns/Corefile",
          "local/zonefile:/etc/coredns/zonefile"
        ]
      }

      service {
        port = "dns"
        name = "coredns"

        check {
          type     = "tcp"
          port     = "dns"
          interval = "10s"
          timeout  = "2s"

          check_restart {
            limit           = 3
            grace           = "30s"
            ignore_warnings = false
          }
        }
      }

      resources {
        cpu    = 150
        memory = 256
      }

      template {
        destination = "local/Corefile"
        change_mode = "restart"
        data        = <<-EOF
          {{- key "${lab_name}/coredns/corefile.tftpl" }}
        EOF
      }

      template {
        destination = "local/zonefile"
        change_mode = "restart"
        data        = <<-EOF
      {{ key "${lab_name}/coredns/zonefile.tftpl" }}
      EOF
      }
    }
  }
}
