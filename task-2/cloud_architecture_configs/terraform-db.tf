# Terraform configuration for Multi-AZ PostgreSQL RDS Database & Read Replica
provider "aws" {
  region = "us-east-1"
}

# Subnet group for RDS deployment across multiple availability zones
resource "aws_db_subnet_group" "db_subnet" {
  name       = "saas-db-subnet-group"
  subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]

  tags = {
    Name        = "SaaS DB Subnet Group"
    Environment = "Production"
  }
}

# DB Security Group allowing access only from the Kubernetes worker nodes
resource "aws_security_group" "db_sg" {
  name        = "saas-db-sg"
  description = "Allow inbound PostgreSQL traffic from EKS worker nodes"
  vpc_id      = "vpc-0123456789abcdef0"

  ingress {
    description     = "PostgreSQL from Kubernetes worker nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["sg-0987654321fedcba0"] # K8s worker node security group ID
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "SaaS DB Security Group"
    Environment = "Production"
  }
}

# Custom Database Parameters (Optimization and Security)
resource "aws_db_parameter_group" "pg_params" {
  name   = "saas-postgres15-parameters"
  family = "postgres15"

  # Performance Tuning
  parameter {
    name  = "shared_buffers"
    value = "{DBInstanceClassMemory/32768}" # Auto-scaling memory pool allocation
  }

  parameter {
    name  = "work_mem"
    value = "16384" # 16MB per query workspace
  }

  # Connection Management
  parameter {
    name  = "max_connections"
    value = "1000"
  }

  # Logging and Auditing
  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "200" # Log queries taking longer than 200ms (slow query log)
  }

  parameter {
    name  = "rds.force_ssl"
    value = "1" # Force SSL encrypted connections
  }
}

# Primary Database (Multi-AZ Master)
resource "aws_db_instance" "db_primary" {
  identifier                  = "saas-db-primary"
  engine                      = "postgres"
  engine_version              = "15.4"
  instance_class              = "db.r6g.xlarge" # Memory-optimized instance
  allocated_storage           = 100
  max_allocated_storage       = 1000            # Autoscale storage up to 1TB
  storage_type                = "gp3"
  db_name                     = "saas_prod"
  username                    = var.db_master_username
  password                    = var.db_master_password
  port                        = 5432
  
  # High Availability & Networking
  multi_az                    = true # Multi-AZ deployment for failover HA
  db_subnet_group_name        = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  publicly_accessible         = false

  # Backup & Maintenance Policies
  backup_retention_period     = 30 # Retain daily snapshots for 30 days
  backup_window               = "03:00-04:00" # Maintenance and snapshot window (UTC)
  copy_tags_to_snapshot       = true
  deletion_protection         = true # Prevent accidental DB deletion
  skip_final_snapshot         = false
  final_snapshot_identifier   = "saas-db-primary-final-snapshot"

  # Performance Insights (Real-time DB query analytics)
  performance_insights_enabled          = true
  performance_insights_retention_period = 7 # 7 days free tier retention

  # Encryption at rest
  storage_encrypted           = true
  kms_key_id                  = "arn:aws:kms:us-east-1:123456789012:key/some-kms-key-uuid"

  parameter_group_name        = aws_db_parameter_group.pg_params.name

  tags = {
    Name        = "SaaS Primary Database"
    Environment = "Production"
  }
}

# Read Replica Database (Provisioned in another AZ for Read Scalability)
resource "aws_db_instance" "db_replica" {
  identifier                  = "saas-db-replica"
  replicate_source_db         = aws_db_instance.db_primary.identifier
  instance_class              = "db.r6g.xlarge"
  storage_type                = "gp3"
  port                        = 5432
  
  # Networking & Security
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  publicly_accessible         = false
  
  # Maintenance
  copy_tags_to_snapshot       = true
  parameter_group_name        = aws_db_parameter_group.pg_params.name

  # Enable read replica performance insight monitoring
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  tags = {
    Name        = "SaaS DB Read Replica"
    Environment = "Production"
  }
}

# Input variables for credentials (injected via Vault or CI secret environment)
variable "db_master_username" {
  type        = string
  description = "Primary DB master admin username"
  sensitive   = true
}

variable "db_master_password" {
  type        = string
  description = "Primary DB master admin password"
  sensitive   = true
}
