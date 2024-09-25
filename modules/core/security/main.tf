terraform {
  backend "s3" {}
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg-${var.environment}"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.allowed_http_cidrs
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "web-sg-${var.environment}"
    }
  )
}

