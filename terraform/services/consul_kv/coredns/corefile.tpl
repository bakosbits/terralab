${domain}.:53 {
  file /etc/coredns/zonefile {
      reload 10s
  }
}
consul.:53 {
  errors
  forward . 127.0.0.1:8600
  log
}

