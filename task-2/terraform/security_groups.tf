# Security Group definitions for SaaS Architecture Layers

# 1. ALB Security Group (Public facing)
resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-alb-sg"
  description = "Allows incoming public web traffic to ALB"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound all
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb-security-group"
    Environment = var.environment
  }
}

# 2. Compute Security Group (Private instances, VMs, or EKS Nodes)
resource "aws_security_group" "compute_sg" {
  name        = "${var.environment}-compute-sg"
  description = "Allows traffic only from the ALB to private compute nodes"
  vpc_id      = aws_vpc.main.id

  # Ingress from ALB (Web/API ports)
  ingress {
    description     = "HTTP traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "Custom application traffic from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # SSH Access from VPC CIDR (Optional secure bastion/internal routing)
  ingress {
    description = "SSH from internal VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Outbound all
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-compute-security-group"
    Environment = var.environment
  }
}

# 3. Database Security Group (Isolated DB subnet)
resource "aws_security_group" "db_sg" {
  name        = "${var.environment}-db-sg"
  description = "Allows DB connections only from the compute instances"
  vpc_id      = aws_vpc.main.id

  # Ingress from Compute SG only
  ingress {
    description     = "PostgreSQL from compute instances"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.compute_sg.id]
  }

  # Outbound block (Databases shouldn't make outbound connections)
  egress {
    description = "Limit outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] # Only talk to internal network
  }

  tags = {
    Name        = "${var.environment}-database-security-group"
    Environment = var.environment
  }
}
