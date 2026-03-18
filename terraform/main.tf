terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ── VPC ───────────────────────────────────────────────────────────────────────
resource "aws_vpc" "cryptozombies_vpc" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags = { Name = "cryptozombies-vpc" }
}

# ── Internet Gateway ──────────────────────────────────────────────────────────
resource "aws_internet_gateway" "cryptozombies_igw" {
  vpc_id = aws_vpc.cryptozombies_vpc.id
  tags   = { Name = "cryptozombies-igw" }
}

# ── Public Subnet ─────────────────────────────────────────────────────────────
resource "aws_subnet" "cryptozombies_subnet" {
  vpc_id                          = aws_vpc.cryptozombies_vpc.id
  cidr_block                      = "10.0.1.0/24"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.cryptozombies_vpc.ipv6_cidr_block, 8, 1)
  availability_zone               = "us-east-1a"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  tags = { Name = "cryptozombies-subnet" }
}

# ── Route Table ───────────────────────────────────────────────────────────────
resource "aws_route_table" "cryptozombies_rt" {
  vpc_id = aws_vpc.cryptozombies_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cryptozombies_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.cryptozombies_igw.id
  }

  tags = { Name = "cryptozombies-rt" }
}

# ── Route Table Association ───────────────────────────────────────────────────
resource "aws_route_table_association" "cryptozombies_rta" {
  subnet_id      = aws_subnet.cryptozombies_subnet.id
  route_table_id = aws_route_table.cryptozombies_rt.id
}

# ── Security Group ────────────────────────────────────────────────────────────
resource "aws_security_group" "cryptozombies_sg" {
  name        = "cryptozombies-sg"
  description = "CryptoZombies DApp security group"
  vpc_id      = aws_vpc.cryptozombies_vpc.id

  ingress {
    description      = "SSH IPv4"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH IPv6"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Frontend IPv4"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Frontend IPv6"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Ganache RPC IPv4"
    from_port        = 8545
    to_port          = 8545
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Ganache RPC IPv6"
    from_port        = 8545
    to_port          = 8545
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "cryptozombies-sg" }
}

# ── EC2 Instance (no user_data) ───────────────────────────────────────────────
resource "aws_instance" "cryptozombies" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  key_name               = "ai-inference-key"
  subnet_id              = aws_subnet.cryptozombies_subnet.id
  vpc_security_group_ids = [aws_security_group.cryptozombies_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = { Name = "cryptozombies-dapp" }
}

# ── Elastic IP ────────────────────────────────────────────────────────────────
resource "aws_eip" "cryptozombies_eip" {
  instance = aws_instance.cryptozombies.id
  domain   = "vpc"
  tags     = { Name = "cryptozombies-eip" }
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "public_ip" {
  value = aws_eip.cryptozombies_eip.public_ip
}

output "frontend_url" {
  value = "http://${aws_eip.cryptozombies_eip.public_ip}:3000"
}

output "ganache_rpc" {
  value = "http://${aws_eip.cryptozombies_eip.public_ip}:8545"
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/ai-inference-key.pem ubuntu@${aws_eip.cryptozombies_eip.public_ip}"
}

output "public_dns" {
  value = "http://ec2-${replace(aws_eip.cryptozombies_eip.public_ip, ".", "-")}.compute-1.amazonaws.com:3000"
}

output "ganache_rpc_dns" {
  value = "http://ec2-${replace(aws_eip.cryptozombies_eip.public_ip, ".", "-")}.compute-1.amazonaws.com:8545"
}