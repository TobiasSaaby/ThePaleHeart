resource "hcloud_network" "k3s_net" {
  name     = "k3s-network"
  ip_range = "10.10.0.0/16"
}

resource "hcloud_network_subnet" "k3s_subnet" {
  network_id   = hcloud_network.k3s_net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.10.1.0/24"
}
