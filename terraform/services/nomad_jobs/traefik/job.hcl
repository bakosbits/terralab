job "traefik" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "traefik" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = "80" }
      port "https" { static = "443" }
    }


    service {
      name = "traefik"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.api.entrypoints=websecure",
        "traefik.http.routers.api.service=api@internal",
        "traefik.http.services.dummy.loadbalancer.server.port=9000",
        "traefik.http.routers.api.middlewares=auth",
      ]

      check {
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"

        check_restart {
          limit           = 3
          grace           = "30s"
          ignore_warnings = false
        }
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:3.6.6"
        ports        = ["http", "https"]
        network_mode = "host"
        volumes = [
          "/mnt/traefik:/etc/traefik",
          "/mnt/certs:/etc/traefik/certs",
          "local/traefik.yaml:/etc/traefik/traefik.yaml",
          "local/dynamic.yaml:/etc/traefik/dynamic/dynamic.yaml"
        ]
      }

      resources {
        cpu    = 250
        memory = 512
      }

      template {
        destination = "local/traefik.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/traefik/traefik.yaml" }}
        EOF
      }

      template {
        destination = "local/dynamic.yaml"
        data        = <<-EOF
        {{- key "${lab_name}/traefik/dynamic.yaml" }}
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
          KEEPALIVED_ROUTER_ID: 55
          KEEPALIVED_STATE: Master
          KEEPALIVED_VIRTUAL_IPS:
            - ${traefik_vip}/24         
          KEEPALIVED_PRIORITY: 100
          KEEPALIVED_INTERFACE: {{ sockaddr "GetPrivateInterfaces | include \"network\" \"${cidr}\" | attr \"name\"" }}
        EOH
      }
    }
  }
}