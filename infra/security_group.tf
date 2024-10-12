resource "aws_security_group" "general-access" {
  name = "general-access"
  description = "dev-group"
  ingress{
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port = 0
    to_port = 0
    protocol = "-1" // all protocols are allowed if -1 is selected
  }
  egress{
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port = 0
    to_port = 0
    protocol = "-1" 
  }
  tags = {
    Name = "general-access"
  }
}