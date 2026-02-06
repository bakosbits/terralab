
bind_addr   = "0.0.0.0"
data_dir    = "/opt/nomad/"
datacenter  = "dc1"
log_level   = "warn"

server {
  enabled = true
  bootstrap_expect = 3
}

advertise {
  http = "{{ GetPrivateIP }}:4646"
  rpc  = "{{ GetPrivateIP }}:4647"
  serf = "{{ GetPrivateIP }}:4648"
}

consul {
  address = "127.0.0.1:8500"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}