variable "vpc_cidr_block" {
  default = "150.0.0.0/16"
}
variable "subnet_cidr_block_public_a" {
  default = "150.0.1.0/24"
}
variable "subnet_cidr_block_public_c" {
  default = "150.0.2.0/24"
}
variable "subnet_cidr_block_private_web_a" {
  default = "150.0.10.0/24"
}
variable "subnet_cidr_block_private_web_c" {
  default = "150.0.20.0/24"
}
variable "az_a" {
  default = "ap-northeast-1a"
}
variable "az_c" {
  default = "ap-northeast-1c"
}

##################################################
# vpc
##################################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

##################################################
# Internet gateway
##################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

##################################################
# public subnet
##################################################
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block_public_a
  availability_zone = var.az_a
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block_public_c
  availability_zone = var.az_c
}

resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_c" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_c.id
}

# public_aがインターネットと通信するためのルーティング。
resource "aws_route" "to_internet_from_public_a" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# public_aがインターネットと通信するためのルーティング。
resource "aws_route" "to_internet_from_public_c" {
  route_table_id         = aws_route_table.public_c.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

##################################################
# private subnet (web)
##################################################
resource "aws_subnet" "private_web_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block_private_web_a
  availability_zone = var.az_a
}

resource "aws_subnet" "private_web_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block_private_web_c
  availability_zone = var.az_c
}

resource "aws_route_table" "private_web_a" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "private_web_c" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private_web_a" {
  subnet_id      = aws_subnet.private_web_a.id
  route_table_id = aws_route_table.private_web_a.id
}

resource "aws_route_table_association" "private_web_c" {
  subnet_id      = aws_subnet.private_web_c.id
  route_table_id = aws_route_table.private_web_c.id
}
