job docker-registry {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "docker-registry" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    network {
      port "http" { static = "5000" }
    }

    volume "docker_registry" {
      type            = "${storage_type}"
      source          = "docker_registry"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }


    service {
      name = "docker-registry"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.docker-registry.entrypoints=websecure"
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "docker-registry" {
      driver = "docker"

      config {
        image        = "docker.io/library/registry:2.8.3"
        network_mode = "host"
        ports        = ["http"]
      }

      volume_mount {
        volume      = "docker_registry"
        destination = "/data"
      }

      env {
        REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY = "/data"
        REGISTRY_HTTP_ADDR                        = "$${NOMAD_ADDR_http}"
        REGISTRY_PROXY_REMOTEURL                  = "https://registry-1.docker.io"
      }

      resources {
        cpu    = 512
        memory = 2048
      }
    }
  }
}
