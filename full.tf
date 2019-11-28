# VPC Creation

provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}" 
}

resource "aws_vpc" "onginx-vpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

# Public Subnet Creation

resource "aws_subnet" "terra_ingress_subnet_az_1" {
  vpc_id     = "${aws_vpc.onginx-vpc.id}"
  cidr_block        = "${var.ingress_subnet_az_1_CIDR}"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "Ingress Subnet 1"
  }

  depends_on = [
    "aws_vpc.onginx-vpc"
  ]
}

resource "aws_subnet" "terra_ingress_subnet_az_2" {
  vpc_id     = "${aws_vpc.onginx-vpc.id}"
  cidr_block        = "${var.ingress_subnet_az_2_CIDR}"
  availability_zone = "ap-south-1b" 
  tags = {
    Name = "Ingress Subnet 2"
  }

  depends_on = [
    "aws_vpc.onginx-vpc"
  ]
}

resource "aws_subnet" "terra_ingress_subnet_az_3" {
  vpc_id     = "${aws_vpc.onginx-vpc.id}"
  cidr_block        = "${var.ingress_subnet_az_3_CIDR}"
  availability_zone = "ap-south-1c"
  tags = {
    Name = "Ingress Subnet 3"
  }

  depends_on = [
    "aws_vpc.onginx-vpc"
  ]
}

# Private Subnet Creation

resource "aws_subnet" "terra_private_subnet_az_1" {
  vpc_id     = "${aws_vpc.onginx-vpc.id}"
  cidr_block        = "${var.private_subnet_az_1_CIDR}"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Application Subnet 1"
  }

  depends_on = [
    "aws_vpc.onginx-vpc"
  ]
}

resource "aws_subnet" "terra_private_subnet_az_2" {
  vpc_id     = "${aws_vpc.onginx-vpc.id}"
  cidr_block        = "${var.private_subnet_az_2_CIDR}"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Application Subnet 1"
  }

  depends_on = [
    "aws_vpc.onginx-vpc"
  ]
}

resource "aws_subnet" "terra_private_subnet_az_3" {
  vpc_id     = "${aws_vpc.onginx-vpc.id}"
  cidr_block        = "${var.private_subnet_az_3_CIDR}"
  availability_zone = "ap-south-1c"

  tags = {
    Name = "Application Subnet 2"
  }

  depends_on = [
    "aws_vpc.onginx-vpc"
  ]
}

# Security Group terra_app_server_sg for public & garrett_terra_alb_sg for private 

resource "aws_security_group" "garrett_terra_alb_sg" {
  name        = "garrett_terra_alb_sg"
  description = "Allow all inbound traffic"
  vpc_id     = "${aws_vpc.onginx-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_az_1_CIDR}"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_az_2_CIDR}"]
  }

   egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_az_3_CIDR}"]
  }


  tags = {
    Name = "garrett_terra_alb_sg"
  }

  depends_on = [
    "aws_vpc.onginx-vpc"
  ]
}

resource "aws_security_group" "terra_app_server_sg" {
  name        = "terra_app_server_sg"
  description = "Allow all inbound traffic"
  vpc_id     = "${aws_vpc.onginx-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.ingress_subnet_az_1_CIDR}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.ingress_subnet_az_2_CIDR}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.ingress_subnet_az_3_CIDR}"]
  }

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ingress_subnet_az_1_CIDR}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ingress_subnet_az_2_CIDR}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ingress_subnet_az_3_CIDR}"]
  }

  tags = {
    Name = "terra_app_server_sg"
  }

  depends_on = [
    "aws_vpc.onginx-vpc"
  ]
}

#Target, LB and Listener


resource "aws_alb_target_group" "terra_alb_target_group" {
  name     = "garrett-terra-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.onginx-vpc.id}"

  depends_on = [
    "aws_vpc.onginx-vpc"
  ]
}

resource "aws_alb" "terra_alb" {
  name               = "garretts-terra-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.garrett_terra_alb_sg.id}"]
  subnets            = ["${aws_subnet.terra_ingress_subnet_az_1.id}","${aws_subnet.terra_ingress_subnet_az_2.id}","${aws_subnet.terra_ingress_subnet_az_3.id}"]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }

  depends_on = [
    "aws_security_group.garrett_terra_alb_sg",
    "aws_subnet.terra_ingress_subnet_az_1",
    "aws_subnet.terra_ingress_subnet_az_2",
    "aws_subnet.terra_ingress_subnet_az_3"
  ]
}

resource "aws_alb_listener" "terra_alb_listener" {
  load_balancer_arn = "${aws_alb.terra_alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.terra_alb_target_group.id}"
    type             = "forward"
  }

  depends_on = [
    "aws_alb.terra_alb",
    "aws_alb_target_group.terra_alb_target_group"
  ]
}

# Create IG

resource "aws_internet_gateway" "terra_gw" {
  vpc_id = "${aws_vpc.onginx-vpc.id}"
  depends_on = [
    "aws_vpc.onginx-vpc"
  ]
}

#Route table for public subnets to IG

resource "aws_route_table" "ingress_route_table" {
  vpc_id = "${aws_vpc.onginx-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terra_gw.id}"
  }

  depends_on = [
    "aws_vpc.onginx-vpc",
    "aws_internet_gateway.terra_gw"
  ]
}

resource "aws_route_table_association" "ingress_route_table_assoc_az_1" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.terra_ingress_subnet_az_1.id}"
  route_table_id = "${aws_route_table.ingress_route_table.id}"

  depends_on = [
    "aws_subnet.terra_ingress_subnet_az_1",
    "aws_route_table.ingress_route_table",
  ]
}

resource "aws_route_table_association" "ingress_route_table_assoc_az_2" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.terra_ingress_subnet_az_2.id}"
  route_table_id = "${aws_route_table.ingress_route_table.id}"

  depends_on = [
    "aws_subnet.terra_ingress_subnet_az_2",
    "aws_route_table.ingress_route_table"
  ]
}

resource "aws_route_table_association" "ingress_route_table_assoc_az_3" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.terra_ingress_subnet_az_3.id}"
  route_table_id = "${aws_route_table.ingress_route_table.id}"

  depends_on = [
    "aws_subnet.terra_ingress_subnet_az_3",
    "aws_route_table.ingress_route_table"
  ]
}

#NAT gateway Creation

resource "aws_eip" "nat_1" {
  vpc = true
}

resource "aws_nat_gateway" "gw_1" {
  allocation_id = "${aws_eip.nat_1.id}"
  subnet_id     = "${aws_subnet.terra_ingress_subnet_az_1.id}"

  tags = {
    Name = "gw NAT 1"
  }
}

#Routing for NAT and pulic

resource "aws_route_table" "app_route_table_1" {
  vpc_id = "${aws_vpc.onginx-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw_1.id}"
  }

  depends_on = [
    "aws_vpc.onginx-vpc",
    "aws_nat_gateway.gw_1"
  ]
}

resource "aws_route_table_association" "app_route_table_assoc_az_1" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.terra_private_subnet_az_1.id}"
  route_table_id = "${aws_route_table.app_route_table_1.id}"

  depends_on = [
    "aws_subnet.terra_private_subnet_az_1",
    "aws_route_table.app_route_table_1"
  ]
}

resource "aws_route_table" "app_route_table_2" {
  vpc_id = "${aws_vpc.onginx-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw_1.id}"
  }

  depends_on = [
    "aws_vpc.onginx-vpc",
    "aws_nat_gateway.gw_1"
  ]
}

resource "aws_route_table" "app_route_table_3" {
  vpc_id = "${aws_vpc.onginx-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw_1.id}"
  }

  depends_on = [
    "aws_vpc.onginx-vpc",
    "aws_nat_gateway.gw_1"
  ]
}

resource "aws_route_table_association" "app_route_table_assoc_az_2" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.terra_private_subnet_az_2.id}"
  route_table_id = "${aws_route_table.app_route_table_2.id}"

  depends_on = [
    "aws_subnet.terra_private_subnet_az_2",
    "aws_route_table.app_route_table_2"
  ]
}

resource "aws_route_table_association" "app_route_table_assoc_az_3" {
  count          = "${var.az_count}"
  subnet_id      = "${aws_subnet.terra_private_subnet_az_3.id}"
  route_table_id = "${aws_route_table.app_route_table_3.id}"

  depends_on = [
    "aws_subnet.terra_private_subnet_az_3",
    "aws_route_table.app_route_table_3"
  ]
}

#ASG for nginx ubuntu

data "aws_ami" "nginx-ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["nginx-plus-ami-ubuntu-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] 
}

resource "aws_launch_configuration" "terra_lc" {
  name_prefix   = "terraform-lc-example-"
  image_id      = "${data.aws_ami.nginx-ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "${var.key_name}"
  security_groups = ["${aws_security_group.terra_app_server_sg.id}"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_security_group.terra_app_server_sg"
  ]
}

resource "aws_autoscaling_group" "terra-app-asg_az_1" {
  name                 = "terraform-asg-example-1"
  launch_configuration = "${aws_launch_configuration.terra_lc.name}"
  min_size             = 2
  max_size             = 4
  vpc_zone_identifier       = ["${aws_subnet.terra_private_subnet_az_1.id}"]
  target_group_arns         = ["${aws_alb_target_group.terra_alb_target_group.id}"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_launch_configuration.terra_lc",
    "aws_subnet.terra_private_subnet_az_1",
    "aws_alb_target_group.terra_alb_target_group"
  ]
}

resource "aws_autoscaling_group" "terra-app-asg_az_2" {
  name                 = "terraform-asg-example-2"
  launch_configuration = "${aws_launch_configuration.terra_lc.name}"
  min_size             = 2
  max_size             = 4
  vpc_zone_identifier       = ["${aws_subnet.terra_private_subnet_az_2.id}"]
  target_group_arns         = ["${aws_alb_target_group.terra_alb_target_group.id}"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_launch_configuration.terra_lc",
    "aws_subnet.terra_private_subnet_az_2",
    "aws_alb_target_group.terra_alb_target_group"
  ]
}

resource "aws_autoscaling_group" "terra-app-asg_az_3" {
  name                 = "terraform-asg-example-3"
  launch_configuration = "${aws_launch_configuration.terra_lc.name}"
  min_size             = 2
  max_size             = 4
  vpc_zone_identifier       = ["${aws_subnet.terra_private_subnet_az_3.id}"]
  target_group_arns         = ["${aws_alb_target_group.terra_alb_target_group.id}"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_launch_configuration.terra_lc",
    "aws_subnet.terra_private_subnet_az_3",
    "aws_alb_target_group.terra_alb_target_group"
  ]
}

resource "aws_route53_record" "www" {
  zone_id = "${var.zone_id}"
  name    = "www.gokuldevops.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_nat_gateway.gw_1.public_ip}"]
}
