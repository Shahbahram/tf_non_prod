variable "profile" {
  type    = string
  default = "default"
}
variable "region-primary" {
  type    = string
  default = "us-west-2"
}
variable "non-prod_vpc_ip" {
  type    = string
  default = "10.17.96.0/20"
}
variable "client_vpn_ip" {
  type    = string
  default = "20.0.0.0/16"
}
variable "instance-type" {
  type    = string
  default = "t3.micro"
  #  validation {
  #    condition     = can(regex("[^t2]", var.instance-type))
  #    error_message = "Instance type cannot be anything other than t2 or t3 type and also not t3a.micro."
  #  }
}
variable "private_key_path" {
  type    = string
  default = "/home/shahm/.ssh/id_rsa"
}
variable "ssh_user" {
  type    = string
  default = "ec2-user"
}
