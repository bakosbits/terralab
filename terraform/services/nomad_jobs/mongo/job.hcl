job "mongo" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "mongo" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "mongo" { static = "27017" }
    }

    service {
      name = "mongo"
      port = "mongo"

      check {
        type     = "tcp"
        port     = "mongo"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "mongo" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "mongo:8.0.14"
        volumes = [
          "local/init-mongo.sh:/docker-entrypoint-initdb.d/init-mongo.sh:ro",
          "/mnt/mongo:/data/db"
        ]
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      template {
        env         = true
        destination = "secrets/mongo.env"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/mongo" }}
          {{- range .Tuples }}
            {{ .K }}={{ .V }}
          {{- end }}
        {{- end }}
        EOF
      }

      template {
        destination = "local/init-mongo.sh"
        perms       = "755"
        data        = <<-EOH
          #!/bin/bash
          {{- with nomadVar "nomad/jobs/mongo" }}
          mongosh <<EOF
          use {{ .MONGO_AUTHSOURCE }}
          db.auth("{{ .MONGO_INITDB_ROOT_USERNAME }}", "{{ .MONGO_INITDB_ROOT_PASSWORD }}")
          db.createUser({
            user: "{{ .MONGO_USER }}",
            pwd: "{{ .MONGO_PASS }}",
            roles: [
              { db: "{{ .MONGO_DBNAME }}", role: "dbOwner" },
              { db: "{{ .MONGO_DBNAME }}_stat", role: "dbOwner" },
              { db: "{{ .MONGO_DBNAME }}_audit", role: "dbOwner" }
            ]
          })
          EOF
          {{- end }}
        EOH
      }
    }
  }
}