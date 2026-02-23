source "proxmox-clone" "client" {
  
  proxmox_url = var.env.proxmox_url
  username    = var.env.proxmox_user
  password    = var.env.proxmox_password
  node        = var.env.proxmox_node
  clone_vm    = "base-tpl"

  insecure_skip_tls_verify = true

  vm_id                = 9002
  vm_name              = "worker-tpl"
  template_description = "nomad client template"
  
  os              = var.env.os
  cpu_type        = var.env.cpu_type
  sockets         = var.env.sockets
  cores           = var.env.cores
  memory          = var.env.memory
  machine         = var.env.machine
  scsi_controller = var.env.scsi_controller
  qemu_agent      = var.env.qemu_agent

  network_adapters {
    model    = var.env.network_adapters_1.model
    bridge   = var.env.network_adapters_1.bridge
  }

  network_adapters {
    model    = var.env.network_adapters_2.model
    bridge   = var.env.network_adapters_2.bridge
  }    
  
  ssh_username = var.env.ssh_username
  ssh_password = var.env.ssh_password
  ssh_timeout  = "20m"
  
}