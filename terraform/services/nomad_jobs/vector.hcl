job "vector" {
  datacenters = ["dc1"]
  type        = "system"

  group "vector" {
    task "vector" {
      driver = "docker"
      user   = "root"

      env {
        # Nomad reads the node name and puts it in an ENV var for Vector
        PARENT_HOST = "$${node.unique.name}"
      }

      config {
        # CHANGE: Using 'debian' instead of 'alpine' so journalctl works
        image = "timberio/vector:latest-debian"
        
        args = ["--config", "/local/vector.yaml"]

        volumes = [
          "/var/log/journal:/var/log/journal:ro",
          "/run/log/journal:/run/log/journal:ro",
          "/etc/machine-id:/etc/machine-id:ro"
        ]
      }

      template {
        destination = "local/vector.yaml"
        left_delimiter  = "[["
        right_delimiter = "]]"
        data = <<EOH
sources:
  proxmox_journal:
    type: journald

transforms:
  process_logs:
    type: remap
    inputs: ["proxmox_journal"]
    source: |
      # Grab the hostname from the ENV var we injected above
      .node_name = get_env_var!("PARENT_HOST")

      .is_flap_event = "false"
      if contains(string!(.message), "arp: moved") {
          .is_flap_event = "true"
      }

sinks:
  loki_out:
    type: loki
    inputs: ["process_logs"]
    endpoint: "http://loki.service.consul:3100"
    encoding:
      codec: json
    labels:
      host: "{{ node_name }}"
      source: "proxmox_host"
      flap: "{{ is_flap_event }}"
EOH
      }
    }
  }
}