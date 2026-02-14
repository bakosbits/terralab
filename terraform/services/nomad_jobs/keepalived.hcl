job "keepalived" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "keepalived" {

    update {
<<<<<<< HEAD
      max_parallel      = 1 
=======
      max_parallel      = 1
>>>>>>> feature/per-volume-node-targeting
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
      auto_revert       = true
    }
<<<<<<< HEAD
        
=======

>>>>>>> feature/per-volume-node-targeting
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
            - ${virtual_ip}/24
          KEEPALIVED_UNICAST_PEERS:
          {{- range service "coredns" }}
            {{- if ne .Address (env "attr.unique.network.ip-address") }}
            - {{ .Address }}
            {{- end }}
          {{- end }}
          KEEPALIVED_PRIORITY: {{ env "PRIORITY" }}
          KEEPALIVED_INTERFACE: {{ sockaddr "GetPrivateInterfaces | include \"network\" \"${cidr}\" | attr \"name\"" }}
        EOH
      }
    }
  }
}
