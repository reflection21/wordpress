variable "cidr_block_vpc" {}
variable "cidr_public_subnets" {}
variable "cidr_private_subnets" {}
variable "cidr_private_subnets_ecr" {}
variable "availability_zone" {}
#=========================================================================================
output "private_subnet_ecr" {
  value = aws_subnet.private_subnets_ecr.*.id
}
output "private_subnets_id" {
  value = aws_subnet.private_subnets.*.id
}
output "public_subnets_id" {
  value = aws_subnet.public_subnets.*.id
}
output "cidr_block_public_subnets" {
  value = aws_subnet.public_subnets.*.cidr_block
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}
#=========================================================================================  

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block_vpc
  tags = {
    Name = "vpc"
  }
}
#=========================================================================================
resource "aws_subnet" "public_subnets" {
  count             = length(var.cidr_public_subnets)
  cidr_block        = element(var.cidr_public_subnets, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.availability_zone, count.index)
  tags = {
    Name = "public_subnet-${count.index + 1}"
  }
}
resource "aws_subnet" "private_subnets" {
  count             = length(var.cidr_private_subnets)
  cidr_block        = element(var.cidr_private_subnets, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.availability_zone, count.index)
  tags = {
    Name = "private_subnet-${count.index + 1}"
  }
}
resource "aws_subnet" "private_subnets_ecr" {
  count             = length(var.cidr_private_subnets_ecr)
  cidr_block        = element(var.cidr_private_subnets_ecr, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.availability_zone, count.index)
  tags = {
    Name = "private_subnet_ecr-${count.index + 1}"
  }
}
#=========================================================================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}
resource "aws_route_table_association" "public_art" {
  count          = length(aws_subnet.public_subnets)
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}
#=========================================================================================
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private_rt"
  }
}
resource "aws_route_table_association" "private_art" {
  count          = length(aws_subnet.private_subnets)
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

resource "aws_route_table_association" "private_art_ecr" {
  count          = length(aws_subnet.private_subnets_ecr)
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnets_ecr[count.index].id
}
#=========================================================================================
