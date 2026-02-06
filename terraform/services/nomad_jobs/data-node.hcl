# No longer used

job "data-node" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "data-node" {

    network {
      port "http" { static = "8999" }
      port "9200" { static = "9200" }
      port "9300" { static = "9300" }
    }

    service {
      name = "data-node"
      port = "http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "data-node" {
      driver = "docker"

      config {
        image        = "graylog/graylog-datanode:6.1"
        ports        = ["http", "9200", "9300"]
        network_mode = "host"
        ulimit {
          memlock = "-1:-1"
          nofile  = "65536:65536"
        }
      }

      env = {
        PUID                                = 1000
        PGID                                = 1000
        GRAYLOG_DATANODE_NODE_ID_FILE       = "/var/lib/graylog-datanode/node-id"
        GRAYLOG_DATANODE_PASSWORD_SECRET    = "somepasswordpepper"
        GRAYLOG_DATANODE_ROOT_PASSWORD_SHA2 = "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918"
        GRAYLOG_DATANODE_MONGODB_URI        = "mongodb://data-node.${consul_domain}:27017/graylog"
        TZ                                  = "America/Denver"
      }

      resources {
        cpu    = 1000
        memory = 1024
      }
    }
  }
}
