variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "num_web" {
  type    = number
  default = 1
}

variable "key_name" {
  type = string
}

variable "allowed_ports_from_public_to_web_ec2" {
  type    = set(number)
  default = []
}

variable "allowed_ports_from_public_to_database_ec2" {
  type    = set(number)
  default = []
}

variable "allowed_ports_from_web_ec2_to_database_ec2" {
  type    = set(number)
  default = []
}

variable "allowed_ports_from_database_ec2_to_web_ec2" {
  type    = set(number)
  default = []
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "web_instance_name" {
  type    = string
  default = "my-ec2"
}

variable "database_instance_name" {
  type    = string
  default = "my-database"
}

variable "db_database" {
  type = string
}
