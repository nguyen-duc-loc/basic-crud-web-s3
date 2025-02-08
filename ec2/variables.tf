variable "key_name" {
  type    = string
  default = ""
}

variable "sg_ids" {
  type = set(string)
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_name" {
  type    = string
  default = "my-ec2"
}

variable "userdata" {
  type    = string
  default = ""
}

variable "iam_instance_profile" {
  type    = string
  default = ""
}
