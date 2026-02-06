# No longer used

job "graylog" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "graylog" {

    network {
      port "http" { static = "9000" }
    }

    service {
      name = "graylog"
      port = "http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "graylog" {
      driver = "docker"

      config {
        image        = "graylog/graylog:6.1"
        ports        = ["http"]
        network_mode = "host"
        volumes = [
          "/mnt/volumes/graylog:/usr/share/graylog/data/config",
          "/mnt/volumes/graylog/data:/usr/share/graylog/data/data",
          "/mnt/volumes/graylog/journal:/usr/share/graylog/data/journal"
        ]
      }

      env {
        PUID                           = 1100
        PGID                           = 1100
        TZ                             = "America/Denver"
        GRAYLOG_NODE_ID_FILE           = ""
        GRAYLOG_HTTP_BIND_ADDRESS      = ""
        GRAYLOG_MONGODB_URI            = ""
        GRAYLOG_REPORT_DISABLE_SANDBOX = true
        GRAYLOG_PASSWORD_SECRET        = ""
        GRAYLOG_ROOT_PASSWORD_SHA2     = ""
        GRAYLOG_HTTP_EXTERNAL_URI      = ""
      }

      resources {
        cpu    = 1000
        memory = 1024
      }
    }
  }
}
