job "coredns" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "coredns" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
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

    task "keepalived" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "osixia/keepalived:2.0.20"
        cap_add      = ["NET_ADMIN", "NET_BROADCAST", "NET_RAW"]
        volumes = [
          "local/:/container/environment/01-custom"
        ]
      }

      template {
        destination = "local/env.yaml"
        change_mode = "restart"
        splay       = "1m"
        data        = <<-EOH
          KEEPALIVED_ROUTER_ID: 50
          KEEPALIVED_STATE: Master
          KEEPALIVED_VIRTUAL_IPS:
            - ${coredns_vip}/24         
          KEEPALIVED_PRIORITY: 100
          KEEPALIVED_INTERFACE: {{ sockaddr "GetPrivateInterfaces | include \"network\" \"${cidr}\" | attr \"name\"" }}
        EOH
      }
    }
  }
}
