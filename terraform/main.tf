# SSH key for login
resource "hcloud_ssh_key" "default" {
  name       = "my-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "hcloud_ssh_key" "yubikey" {
  name       = "my-yubikey"
  public_key = file("~/.ssh/id_ed25519_sk.pub")
}

# Servers
resource "hcloud_server" "vps" {
  name        = "cours"
  server_type = "cx23"
  image       = "ubuntu-26.04"
  location    = "nbg1"
  ssh_keys = [
    hcloud_ssh_key.default.id,
    hcloud_ssh_key.yubikey.id,
  ]


  labels = {
    project = "cours"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

# Outputs
output "server_ip" {
  value = hcloud_server.vps.ipv4_address
}
