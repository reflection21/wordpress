variable "vpc_id" {}
variable "cidr_block_public_subnets" {}
#=========================================================================================
output "sg_22_80" {
  value = aws_security_group.sg_22_80.id
}
output "sg_3306" {
  value = aws_security_group.sg_3306.id
}
output "sg_6379" {
  value = aws_security_group.sg_6379.id
}
#=========================================================================================
resource "aws_security_group" "sg_22_80" {
  vpc_id = var.vpc_id
  name   = "sg for ec2"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name = "sg for ec2"
  }
}

#=========================================================================================
resource "aws_security_group" "sg_3306" {
  vpc_id = var.vpc_id
  name   = "sg for mysql"
  ingress {
    cidr_blocks = var.cidr_block_public_subnets
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }
  tags = {
    Name = "sg for mysql"
  }
}
#=========================================================================================
resource "aws_security_group" "sg_6379" {
  vpc_id = var.vpc_id
  name   = "sg for ecr"
  ingress {
    cidr_blocks = var.cidr_block_public_subnets
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
  }
  tags = {
    Name = "sg for ecr"
  }
}

