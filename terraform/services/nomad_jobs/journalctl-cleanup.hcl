job "journalctl-cleanup" {
  datacenters = ["${datacenter}"]
  type        = "sysbatch"

  periodic {
    crons            = ["@daily"]
    prohibit_overlap = true
  }

  group "garbage_collection" {
    task "garbage_collection" {
      driver = "raw_exec"

      config {
        command = "journalctl"
        args    = ["--vacuum-time", "7d"]
      }
    }
  }
}