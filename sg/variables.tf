variable "sg_name" {
  type = string
}

variable "allowed_ports_from_public" {
  type    = set(number)
  default = []
}

variable "allowed_ports_from_sg" {
  type = list(object({
    sg_id = string
    port  = number
  }))
  default = []
}

variable "allowed_ports_from_private" {
  type = list(object({
    cidr_ipv4 = string
    port      = number
  }))
  default = []
}
