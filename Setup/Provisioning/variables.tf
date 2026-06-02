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
