
server           = true
client_addr      = "0.0.0.0"
advertise_addr   = "{{ GetPrivateIP }}"
bind_addr        = "{{ GetPrivateIP }}"
bootstrap_expect = 3
data_dir         = "/opt/consul"
datacenter       = "dc1"
enable_syslog    = true
log_level        = "warn"
retry_join       = ${retry_join_json}
acl {
    enabled = true
}
ui_config {
    enabled = true
}