resource "hcloud_load_balancer" "k3s_api" {
  name               = "k3s-api-lb"
  load_balancer_type = "lb11"
  location           = var.location

  algorithm {
    type = "round_robin"
  }
}

resource "hcloud_load_balancer_network" "k3s_lb_network" {
  load_balancer_id = hcloud_load_balancer.k3s_api.id
  network_id       = hcloud_network.k3s_net.id

  ip = "10.10.1.5"
}

resource "hcloud_load_balancer_service" "k3s_api" {
  load_balancer_id = hcloud_load_balancer.k3s_api.id

  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
}

resource "hcloud_load_balancer_target" "vps_nodes" {
  depends_on = [
    hcloud_load_balancer_network.k3s_lb_network
  ]

  for_each = {
    for k, v in hcloud_server.vps :
    k => v if v.labels.role == "server"
  }

  load_balancer_id = hcloud_load_balancer.k3s_api.id

  type           = "server"
  server_id      = each.value.id
  use_private_ip = true
}
