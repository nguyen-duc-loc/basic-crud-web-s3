data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.image_id
  iam_instance_profile   = var.iam_instance_profile
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.sg_ids
  user_data              = var.userdata

  tags = {
    Name : var.instance_name
  }
}
