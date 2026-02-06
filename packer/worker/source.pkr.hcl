source "proxmox-clone" "client" {
  
  proxmox_url = var.proxmox_url
  username    = var.proxmox_user
  password    = var.proxmox_password
  node        = var.proxmox_node
  clone_vm    = "base-tpl"

  insecure_skip_tls_verify = true

  vm_id                = 9002
  vm_name              = "worker-tpl"
  template_description = "nomad client template"

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

  
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
  
}