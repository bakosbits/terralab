job "cephfs-controller" {
  datacenters = ["dc1"]
  type        = "service"

  group "cephfs_controller" {

    task "plugin" {
      driver = "docker"

      config {
        image        = "quay.io/cephcsi/cephcsi:v3.17.0"
        network_mode = "host"
        privileged   = true
        volumes = ["/local/config.json:/etc/ceph-csi-config/config.json"]
        args = [
          "--type=cephfs",
          "--controllerserver=true",
          "--drivername=cephfs.csi.ceph.com",
          "--endpoint=unix:///csi/csi.sock",
          "--nodeid=$${node.unique.name}",
          "--instanceid=$${node.unique.name}-controller",
          "--v=5"
        ]
      }

      csi_plugin {
        id        = "cephfs"
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 200
        memory = 256
      }

      template {
        data        = <<EOH
        [
          {
            "clusterID": "${ceph_cluster_id}",
            "monitors": ${ceph_monitors}
          }
        ]
      EOH
        destination = "local/config.json"
      }      
    }
  }
}
