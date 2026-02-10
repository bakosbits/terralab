job "mongo" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "mongo" {

    update {
      canary       = 1 
      auto_promote = true 
      auto_revert  = true 
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }  
    
    network {
      port "mongo" { static = "27017" }
    }

    volume "mongo" {
      type            = "${storage_mode}"
      source          = "mongo"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "mongo"
      port = "mongo"
    }

    task "mongo" {
      driver = "docker"

      config {
        image        = "mongo:8.0.14"
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