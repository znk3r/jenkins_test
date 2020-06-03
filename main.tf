provider "aws" {
  region = "us-west-2"
}

variable "environment_name" {
  description = "Unique name for the environment"
  type        = string
}

variable "environment_tag" {
  description = "Tag for the name of the environment"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the resources are created"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet to use inside the VPC"
  type        = string
}

variable "ssh_key_pair_name" {
  description = "Default EC2 key pair which will have ssh access to all the instances. Check documentation to see which key pair use on each VPC."
  type        = string
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_subnet" "main_subnet" {
  id = var.private_subnet_id
}

data "aws_vpc" "main_vpc" {
  id = "${var.vpc_id}"
}

resource "aws_security_group" "test_instance_sg" {
  name        = join("-", [ "test", var.environment_name, "sg" ])
  description = "Security group to allow ssh access"
  vpc_id      = var.vpc_id

  tags = {
    Name         = join("-", [ "test", var.environment_name, "sg" ])
    ManagedBy    = "terraform"
    Project      = "Testing"
    Environment  = var.environment_tag
  }

  ingress {
    description = "Allow ssh access from inside VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main_vpc.cidr_block]
  }
}

resource "aws_instance" "test" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name  = var.ssh_key_pair_name
  subnet_id = data.aws_subnet.main_subnet.id
  vpc_security_group_ids = [
    aws_security_group.test_instance_sg.id,
  ]

  tags = {
    Name         = join("-", [ "test", var.environment_name, "ubuntu" ])
    ManagedBy    = "terraform"
    Project      = "Testing"
    Environment  = var.environment_tag
  }
}

resource "local_file" "ansible_inventory" {
  filename = "ansible/inventory.yml"
  content = templatefile("ansible_inventory.tmpl", {
    instance_dns = aws_instance.test.private_dns
  })
}


