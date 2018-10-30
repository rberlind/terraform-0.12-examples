provider "aws" {
  region = "us-west-2"
}

variable "vpc_name" {
  description = "name of the VPC"
  default = "rvt-example-vpc"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default = "172.16.0.0/16"
}

variable "subnet_name" {
  description = "name for subnet"
  default = "rvt-example-subnet"
}

variable "subnet_cidr" {
  description = "CIDR for subnet"
  default = "172.16.10.0/24"
}

variable "interface_ips" {
  type = list
  description = "IP for network interface"
  default = ["172.16.10.100"]
}

module "network" {
  source = "./network"
  network_config = {
    vpc_name = var.vpc_name
    vpc_cidr = var.vpc_cidr
    subnet_name = var.subnet_name
    subnet_cidr = var.subnet_cidr
  }
}

resource "aws_network_interface" "rvt" {
  subnet_id = module.network.subnet.id
  private_ips = var.interface_ips
  tags = {
    Name = "rvt-example-interface"
  }
}

resource "aws_instance" "rvt" {
  ami = "ami-22b9a343" # us-west-2
  instance_type = "t2.micro"

  tags = {
    Name = "rvt-example-instance"
  }

  network_interface {
    network_interface_id = aws_network_interface.rvt.id
    device_index = 0
  }
}

output "vpc" {
  value = module.network.vpc
}

output "subnet" {
  value = module.network.subnet
}

output "instance_private_dns" {
  value = aws_instance.rvt.private_dns
}
