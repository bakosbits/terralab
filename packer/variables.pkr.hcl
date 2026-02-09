variable "env" {
  type = object({
    proxmox_url      = string
    proxmox_user     = string
    proxmox_password = string
    proxmox_node     = string
    ssh_username     = string
    ssh_password     = string
  })
}