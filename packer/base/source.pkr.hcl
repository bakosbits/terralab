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
  bios            = "ovmf"

  efi_config {
    efi_storage_pool  = var.env.efi_storage_pool
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  cloud_init              = var.env.cloud_init
  cloud_init_storage_pool = var.env.cloud_init_storage_pool

  vga {
    type = var.env.vga.type
  }

  network_adapters {
    model  = var.env.network_adapters.model
    bridge = var.env.network_adapters.bridge
  }

  disks {
    disk_size    = var.env.disks.disk_size
    storage_pool = var.env.disks.storage_pool
  }

  boot_iso {
    type     = var.env.boot.type
    iso_file = var.env.boot.iso
    unmount  = var.env.boot.unmount
  }

  http_directory = "./http"
  http_port_min  = 8200
  http_port_max  = 8200

  # UEFI/GRUB: move to "Install" (text, 2nd entry), edit it, append preseed to
  # the linux line, then F10. The text entry has no gfxpayload line so the
  # cursor lands directly on linux after pressing e — no <down> needed.
  boot_wait = "5s"
  boot_command = [
    "<wait5>",
    "c",
    "<wait>",
    "linux /install.amd/vmlinuz auto=true url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg priority=critical netcfg/choose_interface=auto --- ",
    "<enter>",
    "initrd /install.amd/initrd.gz",
    "<enter>",
    "boot",
    "<enter>"
  ]
  ssh_username = var.env.ssh_username
  ssh_password = var.env.ssh_password
  ssh_timeout  = "20m"

}
