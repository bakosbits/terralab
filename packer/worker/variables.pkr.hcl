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

    network_adapters = object({
      model  = string
      bridge = string
    })
  })
}
