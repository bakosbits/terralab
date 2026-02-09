source "proxmox-clone" "server" {
  
  proxmox_url = var.env.proxmox_url
  username    = var.env.proxmox_user
  password    = var.env.proxmox_password
  node        = var.env.proxmox_node
  clone_vm    = "base-tpl"

  insecure_skip_tls_verify = true

  vm_id                = 9001
  vm_name              = "manager-tpl"
  template_description = "nomad server template"
  
  os              = "l26"
  cpu_type        = "host"
  sockets         = 1
  cores           = 2
  memory          = 2048
  machine         = "pc"
  scsi_controller = "virtio-scsi-single"
  qemu_agent      = true
  
  cloud_init              = true
  cloud_init_storage_pool = "rbd"

  vga {
    type = "std"
  }

  network_adapters {
    model    = "virtio"    
    bridge   = "vmbr2"
  }
  
  ssh_username = var.env.ssh_username
  ssh_password = var.env.ssh_password
  ssh_timeout  = "20m"
  
}