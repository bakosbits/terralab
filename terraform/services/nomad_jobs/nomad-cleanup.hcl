job "nomad-cleanup" {
  datacenters = ["${datacenter}"]
  type        = "batch"

  periodic {
    crons            = ["@daily"]
    prohibit_overlap = true
  }

  group "garbage_collection" {
    task "garbage_collection" {
      driver = "raw_exec"

      config {
        command = "nomad"
        args    = ["system", "gc", "--address", "${nomad_url}"]
      }
    }
  }
}