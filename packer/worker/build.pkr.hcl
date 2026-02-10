build {
  sources = ["source.proxmox-clone.client"]

  # Copy provisioner up to tmp
  provisioner "file" {
    destination = "/tmp"
    source      = "./scripts"
  }

  # Copy provisioner up to tmp
  provisioner "file" {
    destination = "/tmp"
    source      = "./configs"
  }

  # Provision
  provisioner "shell" {
    inline_shebang  = "/bin/bash -e"
    inline          = ["/bin/bash /tmp/scripts/provision.sh"]
  }

}