build {
  sources = ["source.proxmox-iso.base"]

  # Copy provisioner up to tmp
  provisioner "file" {
    destination = "/tmp"
    source      = "./scripts"
  }

  # Provision
  provisioner "shell" {
    inline_shebang  = "/bin/bash -e"
    inline          = ["/bin/bash /tmp/scripts/provision.sh"]
  }
  
  provisioner "shell" {
    inline = [
      "eject /dev/cdrom"
    ]
  }  
}