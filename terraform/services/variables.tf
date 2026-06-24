locals {
  deployed_jobs = concat(
    var.nomad_jobs.primary.jobs,
    var.nomad_jobs.secondary.jobs,
    var.nomad_jobs.tertiary.jobs
  )
}

variable "env" {
  description = "A map of all environment variables"
  type        = any
  default     = {}
}

variable "nomad_jobs" {
  type = map(object({
    jobs = list(string)
  }))
  description = "A map of nomad jobs in deployment order"
}
