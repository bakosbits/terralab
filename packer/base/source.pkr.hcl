source "proxmox-iso" "base" {
  
  proxmox_url = var.env.proxmox_url
  username    = var.env.proxmox_user
  password    = var.env.proxmox_password
  node        = var.env.proxmox_node

  insecure_skip_tls_verify = true

  vm_id                = 9000
  vm_name              = "base-tpl"
  template_description = "Base VM template"

  os              = var.env.os
  cpu_type        = var.env.cpu_type
  sockets         = var.env.sockets
  cores           = var.env.cores
  memory          = var.env.memory
  machine         = var.env.machine
  scsi_controller = var.env.scsi_controller
  qemu_agent      = var.env.qemu_agent
  
  cloud_init              = var.env.cloud_init
  cloud_init_storage_pool = var.env.cloud_init_storage_pool

  vga {
    type = var.env.vga.type
  }

  network_adapters {
    model    = var.env.network_adapters_1.model
    bridge   = var.env.network_adapters_1.bridge
#    vlan_tag = var.env.network_adapters_1.vlan
  }

  disks {
    disk_size         = var.env.disks.disk_size
    storage_pool      = var.env.disks.storage_pool
  }

  boot_iso {
    type     = var.env.boot.type
    iso_file = var.env.boot.iso
    unmount  = var.env.boot.unmount
  }

  http_directory    = "./http"
  http_port_min     = 8200
  http_port_max     = 8200
  # http_bind_address = var.env.http_bind_address

  boot_wait    = "10s"
  boot_command = [
    "<esc><wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"
  ]

  ssh_username = var.env.ssh_username
  ssh_password = var.env.ssh_password
  ssh_timeout  = "20m"
  
}