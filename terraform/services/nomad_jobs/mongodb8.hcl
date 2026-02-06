job "mongo" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "mongo" {

    network {
      port "mongo" { static = "27017" }
    }

    volume "mongo" {
      type            = "csi"
      source          = "mongo"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      name = "mongo"
      port = "mongo"
    }

    task "mongo" {
      driver = "docker"

      config {
        image        = "mongo:${version}"
        network_mode = "host"
        ports        = ["mongo"]
        volumes = [
          "local/init-mongo.sh:/docker-entrypoint-initdb.d/init-mongo.sh:ro"
        ]
      }

      volume_mount {
        volume      = "mongo"
        destination = "/data/db"
      }

      resources {
        cpu    = ${cpu}
        memory = ${ram}
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