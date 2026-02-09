variable "env" {
  type = any 
  description = "A map of all environment variables"
}

variable "volumes" {
  type = map(object({
    volume_id   = string
    external_id = string
    access_mode = string
  }))
  description = "Volumes for cluster services"
}


variable "consul_kv" {
  type = map(object({
    path_prefix = string
    filenames   = list(string)
    vars        = optional(map(any), {}) 
  }))
  description = "Key-Value pairs for Consul's kv store"
}

variable "nomad_jobs" {
  type = map(object({
    jobs = map(any) 
  }))
}

variable "nomad_vars" {
  type = map(object({
    vars = map(any) 
  }))
}

