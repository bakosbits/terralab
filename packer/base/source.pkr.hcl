source "proxmox-iso" "base" {
  
  proxmox_url = var.proxmox_url
  username    = var.proxmox_user
  password    = var.proxmox_password
  node        = var.proxmox_node
  
  insecure_skip_tls_verify = true

  vm_id                = 9000
  vm_name              = "base-tpl"
  template_description = "Base VM template"

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

  disks {
    disk_size         = "6G"
    storage_pool      = "rbd"
    type              = "scsi"
  }

  boot_iso {
    type     = "scsi"
    iso_file = "local:iso/debian-13.3.0-amd64-netinst.iso"
    unmount  = true
  }

  
  http_directory = "./http"
  http_port_min  = 8200
  http_port_max  = 8200
  boot_wait      = "10s"
  boot_command   = [
    "<esc><wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"
    ]

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
  
}