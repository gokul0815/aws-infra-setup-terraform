variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-south-1"
}

variable "access_key" {
  description = "Access Key"
  default     = ""
}

variable "secret_key" {
  description = "Secret Key"
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default = "10.0.0.0/16"
}

# Az Count


variable "az_count" {
  description = "Availability Count"
  default = "3"
}

# Public Subnet Variables

variable "ingress_subnet_az_1_CIDR" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.1.0/24"
}

variable "ingress_subnet_az_2_CIDR" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.2.0/24"
}

variable "ingress_subnet_az_3_CIDR" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.3.0/24"
}

# Private Subnet Variables

variable "private_subnet_az_1_CIDR" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.4.0/24"
}

variable "private_subnet_az_2_CIDR" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.5.0/24"
}

variable "private_subnet_az_3_CIDR" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.6.0/24"
}

variable "key_name" {
  description = "Key file for servers"
  default = "gokul.pem"
}

variable "zone_id" {
  description = "Zone Id"
  default = ""
}




