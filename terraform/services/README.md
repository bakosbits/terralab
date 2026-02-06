# Add a New Service 

- [Add a new service to an existing cluster](https://github.com/bakosbits/terralab/tree/main/terraform/services#adding-new-services)

# Services Deployment

This directory contains Terraform configurations for deploying services on the Consul/Nomad cluster.

## Overview

The services module manages:

- **Core Services**: Infrastructure components (Traefik, CoreDNS, CSI storage)
- **Data Services**: Databases (PostgreSQL, MongoDB, InfluxDB)
- **Cluster Services**: Applications and workloads (40+ services)
- **Nomad Variables**: Environment variables and secrets
- **Consul KV**: Configuration files
- **CSI Volumes**: Persistent storage for stateful workloads

## Architecture

Services are deployed in three tiers with dependencies:

```
Core Services (Tier 1)
  ├── CoreDNS (service discovery)
  ├── Keepalived (VIP management)
  └── CSI Storage (volume management)
         ↓
Data Services (Tier 2)
  ├── PostgreSQL
  ├── MongoDB
  └── InfluxDB
         ↓
Cluster Services (Tier 3)
  ├── Media (Jellyfin, Plex, etc.)
  ├── Monitoring (Prometheus, Grafana)
  ├── Home Automation (Home Assistant)
  └── Many more...
```

## Files

| File | Purpose |
|------|---------|
| [`providers.tf`](providers.tf) | Nomad and Consul provider configuration |
| [`variables.tf`](variables.tf) | Input variable declarations |
| [`nomad_jobs.tf`](nomad_jobs.tf) | Service job deployments |
| [`nomad_vars.tf`](nomad_vars.tf) | Nomad variables (secrets/env vars) |
| [`nomad_volumes.tf`](nomad_volumes.tf) | CSI volume registrations |
| [`consul_kv.tf`](consul_kv.tf) | Consul KV configuration data |
| [`scheduler.tf`](scheduler.tf) | Nomad scheduler configuration |
| `services.auto.tfvars` | Global variables |
| `services.hcl_vars.auto.tfvars` | Job-specific variables |
| `services.env_vars.auto.tfvars` | Environment variables/secrets |
| `service.volumes.auto.tfvars` | Volume definitions |
| [`nomad_jobs/*.hcl`](nomad_jobs/) | Nomad job specifications |
| [`consul_kv/*`](consul_kv/) | Service configuration files |

## Prerequisites

1. **Cluster deployed** via terraform/cluster
2. **Nomad and Consul** operational
3. **CSI storage** backend available (NFS, Ceph, etc.)
4. **Nomad ACL token** (if ACLs enabled)

## Configuration

### Variable Files

Four main variable files configure the services:

#### 1. Global Variables (`services.auto.tfvars`)

System-wide configuration:

```hcl
global = {
  # Network
  dns1            = "192.168.1.1"
  virtual_ip      = "192.168.1.2"
  
  # Domains
  external_domain = "example.com"
  internal_domain = "example.lan"
  
  # Nomad/Consul URLs
  nomad_url       = "http://192.168.1.71:4646"
  consul_url      = "http://192.168.1.71:8500"
  
  # Datacenter
  datacenter      = "dc1"
  
  # User/timezone
  uid             = "1000"
  gid             = "1000"
  timezone        = "America/Denver"
}
```

#### 2. Job Variables (`services.hcl_vars.auto.tfvars`)

Per-service resource allocation and versions:

```hcl
core_services = {
  traefik = { vars = { version = "3.6.6", cpu = 250, ram = 256 }}
  coredns = { vars = { version = "1.11.1", cpu = 100, ram = 128 }}
}

data_services = {
  postgres = { vars = { version = "18.1", cpu = 1000, ram = 1024 }}
  mongodb8 = { vars = { version = "8.0.14", cpu = 500, ram = 1024 }}
}

cluster_services = {
  jellyfin = { vars = { }}
  grafana  = { vars = { }}
  # ... 40+ more services
}
```

#### 3. Environment Variables (`services.env_vars.auto.tfvars`)

Service-specific environment variables and secrets:

```hcl
env_vars = {
  grafana = {
    vars = {
      GF_SECURITY_ADMIN_USER     = "admin"
      GF_SECURITY_ADMIN_PASSWORD = "changeme"
    }
  }
  
  postgres = {
    vars = {
      POSTGRES_USER     = "postgres"
      POSTGRES_PASSWORD = "changeme"
    }
  }
}
```

⚠️ **Security**: Use proper secrets management (Vault, Nomad Variables ACLs)

#### 4. Volumes (`service.volumes.auto.tfvars`)

CSI volume definitions:

```hcl
volumes = {
  grafana = {
    volume_id   = "grafana"
    external_id = "grafana"              # NFS path
    access_mode = "single-node-writer"
  }
  
  postgres = {
    volume_id   = "postgres"
    external_id = "postgres"
    access_mode = "single-node-writer"
  }
}
```

## Deployment

### Initialize Terraform

```bash
make init-services
# or
cd terraform/services && terraform init
```

### Plan Deployment

```bash
make plan-services
# or
cd terraform/services && terraform plan
```

### Deploy Services

```bash
make deploy-services
# or
cd terraform/services && terraform apply
```

Services deploy in order: Core → Data → Cluster

### Verify Deployment

```bash
# Check job status
nomad job status

# Check specific job
nomad job status traefik

# View allocations
nomad alloc status <alloc-id>

# Check Consul services
consul catalog services
```

## Service Categories

### Core Services

Essential infrastructure components:

- **CoreDNS**: Internal DNS and service discovery  
- **Keepalived**: VIP management for HA
- **storage-controller**: CSI controller plugin
- **storage-node**: CSI node plugin

### Data Services

Database backends:

- **PostgreSQL**: Relational database
- **MongoDB 6/7/8**: Document database (multiple versions)
- **InfluxDB**: Time-series database

### Cluster Services

Applications (40+ services):

**Media**
- Jellyfin, Plex, Sonarr, Radarr, Prowlarr
- SABnzbd, Transmission

**Monitoring**
- Prometheus, Grafana, Loki
- Telegraf, Vector

**Home Automation**
- Home Assistant, MQTT (Mosquitto)
- Matter controller

**Development**
- n8n (workflow automation)
- Wiki.js (documentation)
- Docker Registry

**Networking**
- Cloudflared (tunnels)
- Unifi Controller
- Nginx

**Data Management**
- Graylog (log aggregation)
- pgweb (PostgreSQL UI)

See [`nomad_jobs/`](nomad_jobs/) for all available services.

## Adding New Services

Follow these steps to add a new job to the cluster. Steps marked **Required** are mandatory, while **Optional** steps depend on your service's needs.

### Step 1: Define Volume (Optional)

If your service needs persistent storage, define a volume in [`service.volumes.auto.tfvars`](service.volumes.auto.tfvars):

```hcl
volumes = {
  myservice = {
    volume_id   = "myservice"
    external_id = "myservice"              # NFS path or external volume ID
    access_mode = "single-node-writer"    # See "Volume Management" section
  }
}
```

**Note**: You must also create the volume on your storage backend (e.g., NFS directory) before deploying.

### Step 2: Define Environment Variables (Optional)

If your service requires environment variables or secrets, add them to [`services.env_vars.auto.tfvars`](services.env_vars.auto.tfvars):

```hcl
env_vars = {
  myservice = {
    vars = {
      MY_VAR      = "value"
      MY_SECRET   = "changeme"
      # Add all needed environment variables
    }
  }
}
```

⚠️ **Security**: Consider using Vault or Nomad Variables with ACLs for sensitive data.

### Step 3: Define Job Variables (Required)

Add your service configuration to [`services.hcl_vars.auto.tfvars`](services.hcl_vars.auto.tfvars):

```hcl
# Add to the appropriate tier based on dependencies:
# - core_services    (Tier 1: Infrastructure)
# - data_services    (Tier 2: Databases)
# - cluster_services (Tier 3: Applications)

cluster_services = {
  myservice = {
    vars = {
      version = "1.0"       # Container image version
      cpu     = 100         # CPU in MHz
      ram     = 128         # Memory in MB
      # Add any custom variables your job template needs
    }
  }
}
```

### Step 4: Create Job Definition (Required)

Create your Nomad job specification in [`nomad_jobs/myservice.hcl`](nomad_jobs/):

```hcl
job "myservice" {
  datacenters = ["${datacenter}"]
  type        = "service"
  
  group "myservice" {
    count = 1
    
    network {
      port "http" { to = 8080 }
    }
    
    # If using volume from Step 1
    volume "data" {
      type      = "csi"
      source    = "myservice"
      read_only = false
    }
    
      # Add service registration for Consul
    service {
      name = "myservice"
      port = "http"
      
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.myservice.rule=Host(`myservice.${internal_domain}`)",
      ]
      
      check {
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
            
    }    

    task "myservice" {
      driver = "docker"
      
      config {
        image = "myimage:${version}"
        ports = ["http"]
      }
      

      # If using volume from Step 1
      volume_mount {
        volume      = "data"
        destination = "/data"
      }      
      
      resources {
        cpu    = ${cpu}
        memory = ${ram}
      }

      # If using env vars from Step 2
      template {
        data = <<EOF
{{- with nomadVar "nomad/jobs/myservice" }}
{{- range $k, $v := . }}
{{ $k }}={{ $v }}
{{- end }}
{{- end }}
EOF
        destination = "secrets/env"
        env         = true
      }

    }
  }
}
```

### Step 5: Define Consul KV Config (Optional)

If your service needs configuration files stored in Consul KV, create them in [`consul_kv/myservice/`](consul_kv/):

```bash
# Create directory
mkdir -p consul_kv/myservice

# Create configuration file(s)
cat > consul_kv/myservice/config.yaml <<EOF
# Your service configuration
EOF
```

Then add to [`consul_kv.tf`](consul_kv.tf):

```hcl
resource "consul_keys" "myservice" {
  key {
    path  = "myservice/config"
    value = file("${path.module}/consul_kv/myservice/config.yaml")
  }
}
```

Access in your job template:

```hcl
task "myservice" {
  template {
    data        = "{{ key \"myservice/config\" }}"
    destination = "local/config.yaml"
  }
}
```

### Step 6: Validate and Deploy

```bash
# Validate Nomad job syntax
make validate-jobs

# Plan Terraform changes
make plan-services

# Deploy
make deploy-services
```

### Step 7: Verify Deployment

```bash
# Check job status
nomad job status myservice

# View allocation details
nomad alloc status <alloc-id>

# Check logs
nomad alloc logs <alloc-id>

# Verify service in Consul
consul catalog services | grep myservice
```

## Nomad Job Templates

Jobs use Go templating with variables:

```hcl
job "example" {
  datacenters = ["${datacenter}"]  # From global vars
  
  task "app" {
    config {
      image = "myapp:${version}"    # From job vars
    }
    
    env {
      VAR = "${my_var}"             # From job vars
    }
    
    template {
      data = <<EOF
{{- with nomadVar "nomad/jobs/example" }}
PASSWORD={{ .password }}
{{- end }}
EOF
      destination = "secrets/env"
      env         = true
    }
  }
}
```

## Volume Management

### CSI Plugin Architecture

- **Controller**: Runs on any node, manages volume lifecycle
- **Node**: Runs on all nodes, mounts volumes to tasks

### Creating Volumes

Volumes are registered in Terraform but created externally:

```bash
# NFS example - create directory on NFS server
mkdir -p /exports/cephfs/volumes/myservice
chown 1000:1000 /exports/cephfs/volumes/myservice
```

Then register in `service.volumes.auto.tfvars`.

### Access Modes

- **single-node-writer**: Single node, read-write (most common)
- **single-node-reader-only**: Single node, read-only
- **multi-node-reader-only**: Multiple nodes, read-only
- **multi-node-single-writer**: Multiple nodes, one writer
- **multi-node-multi-writer**: Multiple nodes, all write

## Consul KV Configuration

Service configuration stored in Consul KV:

### Directory Structure

```
consul_kv/
├── traefik/
│   ├── traefik.yaml      # Static config
│   └── dynamic.yaml      # Dynamic config
├── prometheus/
│   └── prometheus.yaml
└── loki/
    └── loki.yaml
```

### Accessing in Jobs

```hcl
task "traefik" {
  template {
    data = <<EOF
{{ key "traefik/config" }}
EOF
    destination = "local/traefik.yaml"
  }
}
```

## Troubleshooting

### Job Won't Start

```bash
# Check job status
nomad job status myservice

# View allocation logs
nomad alloc logs <alloc-id>

# Check events
nomad alloc status <alloc-id>
```

Common issues:
- Resource constraints (CPU/RAM)
- Volume not available
- Image pull failures
- Port conflicts

### Volume Errors

```bash
# Check CSI plugins
nomad plugin status

# Check volume status
nomad volume status myvolume

# Check node plugin allocations
nomad job status storage-node
```

Common issues:
- CSI plugins not running
- Volume path doesn't exist on NFS
- Permission issues

### Service Not in Consul

```bash
# Check Consul catalog
consul catalog services

# Check service instances
consul catalog nodes -service=myservice
```

Common issues:
- Service not registered (missing service stanza)
- Health checks failing
- Consul agent issues

### Environment Variables Not Set

Check Nomad variables:

```bash
# List variables
nomad var list

# Get specific variable
nomad var get nomad/jobs/myservice
```

### Network Issues

- Verify Consul DNS: `dig @127.0.0.1 -p 8600 myservice.service.consul`
- Check Traefik logs for routing issues
- Verify network mode in job (bridge vs host)

## Scheduler Configuration

The [`scheduler.tf`](scheduler.tf) configures Nomad scheduler:

- Enables preemption (if configured)
- Sets scheduler algorithm
- Configures spread and affinity

## State Management

Like cluster, consider remote state for production:

```hcl
terraform {
  backend "consul" {
    address = "consul.example.com:8500"
    path    = "terraform/services"
  }
}
```

## Maintenance

### Updating Services

```bash
# Update version in services.hcl_vars.auto.tfvars
# Then apply
terraform apply
```

Nomad will rolling-update allocations.

### Scaling Services

Modify count in job file:

```hcl
group "myservice" {
  count = 3  # Scale to 3 instances
}
```

### Validating Jobs

Before applying:

```bash
make validate-jobs
# or
./scripts/validate-jobs.sh
```

### Formatting

```bash
make format
```

## Security Best Practices

1. **Use Nomad Variables** with ACLs for secrets
2. **Enable Consul ACLs** for service mesh
3. **Use namespace isolation** in Nomad
4. **Implement network segmentation**
5. **Regular security updates** of container images
6. **Encrypt Nomad/Consul traffic** with TLS
7. **Audit access** with logging

## Performance Tuning

### Resource Allocation

Monitor and adjust:

```hcl
resources {
  cpu    = 1000  # MHz
  memory = 2048  # MB
}
```

### Placement

Use constraints and affinity:

```hcl
constraint {
  attribute = "${node.class}"
  value     = "high-memory"
}
```

### Storage Performance

- Use local storage for temporary data
- NFS for shared, persistent data
- Ceph RBD for high-performance block storage

## Monitoring

Access monitoring services:

- **Grafana**: http://grafana.yourdomain.com
- **Prometheus**: http://prometheus.yourdomain.com
- **Nomad UI**: http://192.168.1.71:4646
- **Consul UI**: http://192.168.1.71:8500

## Reference

- [Nomad Job Specification](https://www.nomadproject.io/docs/job-specification)
- [Consul KV Store](https://www.consul.io/docs/dynamic-app-config/kv)
- [CSI Plugins](https://www.nomadproject.io/docs/internals/plugins/csi)
- [Nomad Variables](https://www.nomadproject.io/docs/concepts/variables)
