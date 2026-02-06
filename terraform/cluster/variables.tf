variable "provider" {
  type        = map(any)
  description = "Variables for the providers, such as urls and credentials"
}

variable "global" {
  type        = map(any)
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

