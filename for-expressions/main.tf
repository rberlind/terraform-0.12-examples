terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  default = "us-east-1"
}

variable "azs" {
  description = "AWS availability zones to use"
  default = ["a", "b", "c"]
}

resource "aws_instance" "ubuntu" {
  count = 3
  ami           = "ami-2e1ef954"
  instance_type = "t2.micro"
  availability_zone = format("%s%s", var.aws_region, var.azs[count.index])
  associate_public_ip_address = true
  tags = {
    Name  = format("terraform-0.12-for-demo-%d", count.index)
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
}

# This uses the old splat expression
output "public_addresses_old" {
  value = aws_instance.ubuntu.*.public_dns
}

# This uses the new for expression
output "public_addresses_new" {
  value = [
    for instance in aws_instance.ubuntu:
    instance.public_dns
  ]
}

# Convert azs to upper-case as list
output "upper-azs-list" {
  value = [for z in var.azs: upper(z)]
}

# Convert azs to upper-case as map
output "upper-azs-map" {
  value = {for z in var.azs: z => upper(z)}
}
