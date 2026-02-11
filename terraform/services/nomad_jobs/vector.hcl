job "vector" {
  datacenters = ["dc1"]
  type        = "system"

  group "vector" {

    update {
      max_parallel      = 1 
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
      auto_revert       = true
    }

    task "vector" {
      driver = "docker"
      user   = "root"

      env {
        # Nomad reads the node name and puts it in an ENV var for Vector
        PARENT_HOST = "$${node.unique.name}"
      }

      config {
        image = "timberio/vector:latest-debian"
        
        args = ["--config", "/local/vector.yaml"]

        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro",
          "/var/log/journal:/var/log/journal:ro",
          "/run/log/journal:/run/log/journal:ro",
          "/etc/machine-id:/etc/machine-id:ro"
        ]
      }

      template {
        destination = "local/vector.yaml"
        left_delimiter  = "[["
        right_delimiter = "]]"
        data        = <<-EOF
        [[- key "terralab/vector/vector.yaml" ]]
      EOF
      }
    }  
  }
}