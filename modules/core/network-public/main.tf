terraform {
  backend "s3" {}
}

# Data source to get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Local map for region short code
locals {
  region_short_code = {
    "us-east-1" = "use1"
    "us-west-2" = "usw2"
    # Add more regions if needed
  }

  az_name_to_id_suffix = {
    for idx, az in data.aws_availability_zones.available.names :
    az => replace(data.aws_availability_zones.available.zone_ids[idx], "${var.region}-", "")
  }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  for_each = { for subnet in var.public_subnets : "${subnet.availability_zone}-${subnet.servicetype}" => subnet }

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      "Name" = "public-subnet-${each.value.servicetype}-${local.az_name_to_id_suffix[each.value.availability_zone]}-${var.env}"
      "servicetype" = each.value.servicetype
    }
  )
}

# Conditional Creation of IGW + NAT Gateway
resource "aws_internet_gateway" "igw" {
  count = var.nat_gateway_enabled ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "igw-${local.region_short_code[var.region]}-${var.env}"
    }
  )
}

resource "aws_eip" "nat" {
  count = var.nat_gateway_enabled ? 1 : 0
  domain = "vpc"
  tags = merge(
    var.tags,
    {
      "Name" = "eip-nat-${local.region_short_code[var.region]}-${var.env}"
    }
  )
}

resource "aws_nat_gateway" "nat" {
  count = var.nat_gateway_enabled ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public["us-east-1a-default"].id  # NAT Gateway goes in a public subnet

  tags = merge(
    var.tags,
    {
      "Name" = "nat-gateway-${local.region_short_code[var.region]}-${var.env}"
    }
  )
}

# Security Group for NAT Instance
resource "aws_security_group" "nat_sg" {
  count = var.nat_gateway_enabled ? 0 : 1  # Only create this SG if NAT Gateway is disabled (i.e., using NAT Instance)

  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from private subnets"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Adjust CIDR to match your private subnets
  }

  ingress {
    description = "Allow SSH access (optional)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Or restrict to your admin IP
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      "Name" = "sg-nat-instance-${local.region_short_code[var.region]}-${var.env}"
    }
  )
}

# NAT Instance
resource "aws_instance" "nat_instance" {
  count = var.nat_gateway_enabled ? 0 : 1  # Create NAT Instance only if NAT Gateway is disabled
  ami = "ami-0c55b159cbfafe1f0"  # Use a NAT-specific AMI (Amazon Linux 2 or similar)
  instance_type = "t3.micro" 
  subnet_id     = aws_subnet.public["us-east-1a-default"].id
  vpc_security_group_ids = [aws_security_group.nat_sg[0].id]  # Attach the NAT Security Group

  tags = merge(
    var.tags,
    {
      "Name" = "nat-instance-${local.region_short_code[var.region]}-${var.env}"
    }
  )
}


# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.nat_gateway_enabled ? aws_internet_gateway.igw[0].id : aws_instance.nat_instance[0].id
  }

  tags = merge(
    var.tags,
    {
      "Name" = "public-rt-${local.region_short_code[var.region]}-${var.env}"
    }
  )
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

