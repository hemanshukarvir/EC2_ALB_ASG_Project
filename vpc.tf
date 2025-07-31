#VPC Creation block
resource "aws_vpc" "tf_vpc" {
  cidr_block = "192.168.0.0/24"
    tags = {
    Name = "vpc-terraform"
  }
}

#SUBNET Creation
#Public Subnet
resource "aws_subnet" "tf_public_subnet" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = "192.168.0.0/27"
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "tf_public_subnet_2" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = "192.168.0.64/27"
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1b"
}

#Private Subnet
resource "aws_subnet" "tf_private_subnet" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = "192.168.0.32/27"
  map_public_ip_on_launch = false
}

#Internet Gateway
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id
}

#Route Table
resource "aws_route_table" "tf_rt" {
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }
}

resource "aws_route_table_association" "tf_rt_association" {
    route_table_id = aws_route_table.tf_rt.id
    subnet_id = aws_subnet.tf_public_subnet.id
}

resource "aws_route_table_association" "tf_rt_association_2" {
    route_table_id = aws_route_table.tf_rt.id
    subnet_id = aws_subnet.tf_public_subnet_2.id
}

#Security Group for ALB for HTTP traffic from internet
resource "aws_security_group" "tf_sg_alb" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name ="ALB SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tf_sg_alb_ingress" {
  security_group_id = aws_security_group.tf_sg_alb.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port   = 80
    ip_protocol = "TCP"
    to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "tf_sg_alb_egress" {
  security_group_id = aws_security_group.tf_sg_alb.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port   = -1
    ip_protocol = "-1"
    to_port     = -1
}

#Security Group for EC2 with SSH/HTTP traffic from Internet/ALB
resource "aws_security_group" "tf_sg_ec2" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name ="EC2 SG"
  }
  name = "EC2 SG"
}

resource "aws_vpc_security_group_ingress_rule" "tf_sg_ec2_ssh_ingress" {
  security_group_id = aws_security_group.tf_sg_ec2.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "TCP"
    to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "tf_sg_ec2_http_ingress" {
    security_group_id = aws_security_group.tf_sg_ec2.id
    referenced_security_group_id = aws_security_group.tf_sg_alb.id
    from_port   = 80
    ip_protocol = "TCP"
    to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "tf_sg_ec2_egress" {
  security_group_id = aws_security_group.tf_sg_ec2.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port   = "-1"
    ip_protocol = "-1"
    to_port     = "-1"
}

