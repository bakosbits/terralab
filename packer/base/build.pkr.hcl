build {
  sources = ["source.proxmox-iso.base"]

  provisioner "file" {
    destination = "/tmp"
    source      = "./scripts"
  }

  provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    inline         = ["/bin/bash /tmp/scripts/provision.sh"]
  }
}
