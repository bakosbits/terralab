job "keepalived" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "keepalived" {

    task "keepalived" {
      driver = "docker"

      config {
        network_mode = "host"        
        image        = "osixia/keepalived:2.0.20"
        cap_add = ["NET_ADMIN", "NET_BROADCAST", "NET_RAW"]
        volumes = [
          "local/:/container/environment/01-custom"
        ]
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
                KEEPALIVED_PRIORITY: {{ if eq (env "node.unique.name") "worker03" }}150{{ else }}100{{ end }}
                KEEPALIVED_INTERFACE: {{ sockaddr "GetPrivateInterfaces | include \"network\" \"192.168.1.0/24\" | attr \"name\"" }}
              EOH
      }
    }
  }
}
