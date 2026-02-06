job docker_registry {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "docker_registry" {

    network {
      port "http" { static = "5000" }
    }

    volume "docker_registry" {
      type            = "csi"
      source          = "docker_registry"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    service {
      port = "http"
      name = "$${NOMAD_JOB_NAME}"

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "docker_registry" {
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
