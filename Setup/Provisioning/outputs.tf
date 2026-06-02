output "ansible_inventory" {
  value = join("\n", concat(
    ["[k3s_servers]"],
    [
      for name, server in hcloud_server.vps :
      "${name} ansible_host=${server.ipv4_address} local_ip=${one(server.network[*].ip)}"
    ],
    [
      "",
      "[k3s_servers:vars]",
      "ansible_user=root",
      "ansible_ssh_private_key_file=~/.ssh/id_ed25519",
      "ansible_python_interpreter=/usr/bin/python3"
    ],
    [
      "",
      "[k3s_lb]",
      "api_lb ansible_host=${hcloud_load_balancer.k3s_api.ipv4}"
    ]
  ))
}
