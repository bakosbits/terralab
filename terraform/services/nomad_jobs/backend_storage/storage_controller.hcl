job "storage_controller" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "controller" {

    update {
      canary            = 1
      auto_promote      = true
      auto_revert       = true
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
    }

    task "controller" {
      driver = "docker"

      config {
        image = "registry.gitlab.com/rocketduck/csi-plugin-nfs:1.1.0"

        args = [
          "--type=controller", 
          "--node-id=$${attr.unique.hostname}",
          "--nfs-server=192.168.1.225:/exports/cephfs/volumes",
          "--mount-options=nfsvers=4.1,noatime,nodiratime,soft,timeo=30,retrans=2,rsize=1048576,wsize=1048576",
          "--allow-nested-volumes"
        ]

        network_mode = "host"
        privileged   = true
      }

      resources {
        cpu    = 500
        memory = 256
      }

      csi_plugin {
        id             = "nfs"
        type           = "controller"
        mount_dir      = "/csi"
        health_timeout = "120s"
      }
    }
  }
}