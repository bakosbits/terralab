job "prometheus" {
  datacenters = ["dc1"]
  
  group "prometheus" {
    network {
      port "http" { static = 9090 }
    }

    service {
      name = "prometheus"
      port = "http"
    }

    task "prometheus" {
      driver = "docker"
      config {
        image = "prom/prometheus:latest"
        ports = ["http"]
        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus"
        ]
      }

      template {
        data = <<EOH
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'nomad_nodes'
    consul_sd_configs:
      - server: '127.0.0.1:8500' # Assumes Consul is running
    relabel_configs:
      - source_labels: [__meta_consul_service]
        regex: 'node-exporter'
        action: keep
EOH
        destination = "local/prometheus.yml"
      }
    }
  }
}