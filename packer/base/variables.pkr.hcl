variable "env" {
  type = object({
    proxmox_url      = string
    proxmox_user     = string
    proxmox_password = string
    proxmox_node     = string
    ssh_username     = string
    ssh_password     = string

    os              = string
    cpu_type        = string
    sockets         = number
    cores           = number
    memory          = number
    machine         = string
    scsi_controller = string
    qemu_agent      = bool

    cloud_init              = bool
    cloud_init_storage_pool = string
    iso_storage_pool        = string
    http_bind_address       = string

    vga = object({
      type = string
    })

    network_adapters_1 = object({
      model  = string
      bridge = string
      vlan   = number
    })

    disks = object({
      disk_size         = string
      storage_pool      = string
    })

    boot = object({
      type    = string
      iso     = string
      unmount = bool
    })
  })
}