variable "proxmox_url" {
  type        = string
  description = "the url of proxmox"
}

variable "proxmox_user" {
  type        = string
  description = "the api user being used to connect the provider"
}

variable "proxmox_password" {
  type        = string
  sensitive   = true
  description = "the password for the api user being used by the provider"
}

variable "proxmox_node" {
  type        = string
  description = "the proxmox node being deployed to"
}

variable "ssh_username" {
  type       = string
  sensitive  = true
  description = "the user being used for provisioning"
}

variable "ssh_password" {
  type        = string
  sensitive   = true
  description = "the password of the provisioning user"
}