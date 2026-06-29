variable "servers" {
  type = map(object({
    ip   = string
    role = string
  }))
}

variable "location" {
  type    = string
  default = "hel1"
}

variable "network_ip_range" {
  type    = string
  default = "10.10.0.0/16"
}

variable "network_subnet_ip_range" {
  type    = string
  default = "10.10.1.0/24"
}

variable "network_zone" {
  type    = string
  default = "eu-central"
}

variable "k3s_load_balancer_private_ip" {
  type    = string
  default = "10.10.1.5"
}

variable "k3s_server_type" {
  type    = string
  default = "cx33"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "development_vps" {
  type = object({
    enabled        = bool
    name           = string
    private_ip     = string
    server_type    = string
    image          = string
    ssh_source_ips = list(string)
    nixos_host     = string
    nixos_disk     = string
  })

  default = {
    enabled        = false
    name           = "failsafe-1"
    private_ip     = "10.10.1.50"
    server_type    = "cx33"
    image          = "ubuntu-24.04"
    ssh_source_ips = ["0.0.0.0/0", "::/0"]
    nixos_host     = "failsafe"
    nixos_disk     = "/dev/sda"
  }
}
