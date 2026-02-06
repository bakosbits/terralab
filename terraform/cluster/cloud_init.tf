# Local vars to support the cloud-init resource

locals {
  # --- Template Injections ---
  retry_join_json = jsonencode([for m in local.manager_nodes : m.ip])
  
  nomad_manager_hcl = file("${path.module}/templates/nomad_manager.tpl")
  nomad_worker_hcl  = file("${path.module}/templates/nomad_worker.tpl")

  consul_manager_hcl = templatefile("${path.module}/templates/consul_manager.tpl", {
    retry_join_json = local.retry_join_json
  })

  consul_worker_hcl = templatefile("${path.module}/templates/consul_worker.tpl", {
    retry_join_json = local.retry_join_json
  })

  # Role mapper (worker, manager)
  role_mapper = {

    manager = <<-EOT
  - path: /etc/consul.d/consul.hcl
    content: |
      ${indent(6, local.consul_manager_hcl)}
  - path: /etc/nomad.d/nomad.hcl
    content: |
      ${indent(6, local.nomad_manager_hcl)}
EOT

    worker = <<-EOT
  - path: /etc/consul.d/consul.hcl
    content: |
      ${indent(6, local.consul_worker_hcl)}
  - path: /etc/nomad.d/nomad.hcl
    content: |
      ${indent(6, local.nomad_worker_hcl)}
EOT
  }

}

# Cloud-init config for each host and role: consul, nomad, coredns
# This needs to be available to all the vm hosts 

resource "proxmox_virtual_environment_file" "cloud_init" {
  for_each     = local.all_nodes
  node_name    = var.pve_nodes[0]
  datastore_id = var.vm.cloud_init_storage
  content_type = "snippets"

  source_raw {
    file_name = "${each.value.name}-setup.yaml"
    data      = <<-EOF
#cloud-config
hostname: ${each.value.name}
manage_etc_hosts: true
users:
  - default # Adds the default user for the OS (optional)
  - name: ${var.global.ciuser}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ${trimspace(var.global.sshkeys)}
# Optional: Set the password for console access if SSH fails
chpasswd:
  list: |
    ${var.global.ciuser}:${var.global.cipassword}
  expire: False
package_update: true
write_files:
  # Role-specific config (consul, nomad, coredns)
${local.role_mapper[each.value.role]}
runcmd:
  - echo "nameserver ${var.global.dns1}" | sudo tee /etc/resolv.conf
  - systemctl daemon-reload
  - systemctl enable --now consul  
  - systemctl enable --now nomad    
  - echo "done" > /tmp/cloud-config.done
EOF
  }
}


