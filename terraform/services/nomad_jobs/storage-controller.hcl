job "storage-controller" {
  datacenters = ["${datacenter}"]
  type        = "service"

  group "controller" {

    task "controller" {
      driver = "docker"

      config {
        image = "registry.gitlab.com/rocketduck/csi-plugin-nfs:1.1.0"

        args = [
          "--type=controller",
          "--node-id=$${attr.unique.hostname}",
          "--nfs-server=${nfs_server}",
          "--mount-options=nfsvers=4.1,noatime,nodiratime,soft,timeo=30,retrans=2,rsize=1048576,wsize=1048576",
          "--allow-nested-volumes"
        ]

        network_mode = "host"
        privileged   = true
      }

      csi_plugin {
        id        = "nfs"
        type      = "controller"
        mount_dir = "/csi"
      }
    }
  }
}