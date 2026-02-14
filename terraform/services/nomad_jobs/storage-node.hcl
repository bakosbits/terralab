job "storage-node" {
  datacenters = ["${datacenter}"]
  type        = "system"

  group "node" {

    update {
      max_parallel      = 1
      min_healthy_time  = "30s"
      healthy_deadline  = "5m"
      progress_deadline = "10m"
      auto_revert       = true
    }

    task "node" {
      driver = "docker"

      config {
        image = "registry.gitlab.com/rocketduck/csi-plugin-nfs:${version}"
        args = [
          "--type=node",
          "--node-id=$${attr.unique.hostname}",
          "--nfs-server=192.168.1.225:/exports/cephfs/volumes",
          "--mount-options=nfsvers=4.1,noatime,nodiratime,soft,timeo=30,retrans=2,rsize=1048576,wsize=1048576",
          "--allow-nested-volumes"
        ]

        network_mode = "host"
        privileged   = true
      }

      csi_plugin {
        id        = "nfs"
        type      = "node"
        mount_dir = "/csi"
      }
    }
  }
}