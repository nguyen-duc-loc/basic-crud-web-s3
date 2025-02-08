resource "aws_security_group" "sg" {
  name = var.sg_name
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_from_public" {
  security_group_id = aws_security_group.sg.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  for_each  = toset([for port in var.allowed_ports_from_public : tostring(port)])
  from_port = each.value
  to_port   = each.value
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_from_sg" {
  count = length(var.allowed_ports_from_sg)

  security_group_id = aws_security_group.sg.id
  ip_protocol       = "tcp"

  referenced_security_group_id = var.allowed_ports_from_sg[count.index].sg_id
  from_port                    = var.allowed_ports_from_sg[count.index].port
  to_port                      = var.allowed_ports_from_sg[count.index].port
}

resource "aws_vpc_security_group_egress_rule" "sg_egress" {
  security_group_id = aws_security_group.sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_from_private" {
  count = length(var.allowed_ports_from_private)

  security_group_id = aws_security_group.sg.id
  ip_protocol       = "tcp"

  cidr_ipv4 = var.allowed_ports_from_private[count.index].cidr_ipv4
  from_port = var.allowed_ports_from_private[count.index].port
  to_port   = var.allowed_ports_from_private[count.index].port
}
