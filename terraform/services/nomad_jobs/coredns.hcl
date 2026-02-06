job "coredns" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "coredns" {

    network {
      mode = "host"
      port "dns" { static = 53 }
    }

    task "coredns" {
      driver = "docker"

      config {
        image        = "coredns/coredns:${version}"
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
        }
      }

      template {
        destination = "local/Corefile"
        change_mode = "restart"
        data        = <<-EOF
{{- key "homelab/coredns/Corefile" }}
EOF
      }

      template {
        destination = "local/zonefile"
        change_mode = "restart"
        data        = <<-EOF
{{- key "homelab/coredns/zonefile" }} 
EOF
      }

      resources {
        cpu    = ${cpu}
        memory = ${ram}
      }
    }
  }
}