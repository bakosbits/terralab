
bind_addr = "0.0.0.0"
data_dir = "/opt/nomad/"
datacenter = "dc1"
log_level = "warn"

client {
    enabled = true   
    options = {
        docker.privileged.enabled = true
        docker.volumes.enabled = true
        docker.caps.whitelist = "ALL"
        driver.raw_exec.enable = "1"
    }
}

consul {
    address = "127.0.0.1:8500"
    client_service_name = "nomad-client"
    auto_advertise = true
    server_auto_join = true
    client_auto_join = true
}

telemetry {
    collection_interval = "5s"
    disable_hostname = false
    prometheus_metrics = true
    publish_allocation_metrics = true
    publish_node_metrics = true
}

plugin "docker" {
    config {
        extra_labels = ["job_name", "job_id", "task_group_name", "task_name", "namespace", "node_name", "node_id"]
        allow_caps = ["CHOWN","DAC_OVERRIDE","FSETID","FOWNER","MKNOD","NET_RAW","SETGID","SETUID","SETFCAP","SETPCAP"," NET_BIND_SERVICE","SYS_CHROOT","NET_ADMIN","NET_RAW","NET_BROADCAST"]
        allow_privileged = true
        volumes {
        enabled = true
        }
    }
}