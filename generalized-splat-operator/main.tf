resource "aws_security_group" "allow_some_ingress" {
  name        = "allow_some_ingress"
  description = "Allow some inbound traffic"
  vpc_id      = "vpc-0e56931573507c9dd"

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ports" {
  value = aws_security_group.allow_some_ingress.ingress.*.from_port
}
