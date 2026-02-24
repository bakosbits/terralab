job "keepalived" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "keepalived" {

    update {
      max_parallel      = 1
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
      auto_revert       = true
    }

    service {
      name = "keepalived"
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

      env {
        PRIORITY = "$${meta.keepalived_priority}"
      }

      template {
        destination = "local/env.yaml"
        change_mode = "restart"
        splay       = "1m"
        data        = <<-EOH
          KEEPALIVED_ROUTER_ID: 75
          KEEPALIVED_VIRTUAL_IPS:
            - ${keepalived_vip}/24
          KEEPALIVED_PRIORITY: {{ env "PRIORITY" }}
          KEEPALIVED_INTERFACE: {{ sockaddr "GetDefaultInterfaces | attr \"name\"" }}
        EOH
      }
    }
  }
}
