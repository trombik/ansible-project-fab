provider "aws" {
  region     = "ap-northeast-1"
}

variable "project" {
  default = "fab"
}

# can be overrided by TF_VAR_stage environment variable
variable "environment" {
  default = "staging"
}

variable "fqdn" {
  type = string
  default = "fab.mkrsgh.org"
}

variable "groups" {
  type = string
  default = "fab,staging_credentials,staging"
}

variable "ports_tcp_public" {
  type = list(number)
  default = [22, 80, 443]
}

variable "ports_udp_public" {
  type = list(number)
  default = []
}

resource "aws_security_group" "fab" {
  name                          = "security_group_fab"
  description                   = "Security group for fab-manager"
  vpc_id                        = "vpc-7a87641e"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.ports_tcp_public
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.ports_udp_public
    iterator = udp_port
    content {
      from_port = udp_port.value
      to_port   = udp_port.value
      protocol  = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "fab" {
  instance = aws_instance.fab.id
  vpc      = true
}

resource "aws_instance" "fab" {
  key_name                      = "trombik-ed"
  instance_type                 = "t3a.medium"
  # FreeBSD 13.1-RC6-amd64 UEFI
  ami                           = "ami-019a1b29c4475470d"
  vpc_security_group_ids        = ["${aws_security_group.fab.id}"]
  subnet_id                     = "subnet-293b9c5f"
  tags                          = { "Name" = var.fqdn, "Environment" = var.environment, "Project" = var.project, "Groups" = var.groups }
  user_data                     = file("${path.module}/freebsd.sh")
  root_block_device {
    delete_on_termination = false
    volume_type = "gp2"
    volume_size = 32
  }
}
