
server      = false
client_addr = "0.0.0.0"
bind_addr   = "{{ GetPrivateIP }}"
data_dir    = "/opt/consul"
datacenter  = "dc1"
retry_join  = ${retry_join_json}
log_level   = "warn"