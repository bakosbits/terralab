variable "provider_vars" {
  type        = map(any)
  description = "Variables for the providers, such as urls and credentials"
}

variable "pve_nodes" {
  type        = list(string)
  default     = ["pve01", "pve02", "pve03"] 
  description = "PVE node names"
}

variable "global" {
  type        = map(string)
  description = "Variables used globally"
}

variable "worker" {
  type        = map(any)
  description = "Variables used for worker nodes"
}

variable "manager" {
  type        = map(any)
  description = "Variables used manager nodes"
}

variable "vm" {
  type        = map(any)
  description = "Variables used for vms"
}

