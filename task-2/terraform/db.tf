# AWS RDS PostgreSQL Database Configuration

# DB Subnet Group deploying DB across isolated database subnets
resource "aws_db_subnet_group" "db_subnet" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = [for s in aws_subnet.database : s.id]

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# Custom Parameter Group for Postgres Optimization
resource "aws_db_parameter_group" "pg_params" {
  name   = "${var.environment}-postgres15-parameters"
  family = "postgres15"

  # Performance metrics tuning
  parameter {
    name  = "shared_buffers"
    value = "{DBInstanceClassMemory/32768}"
  }

  parameter {
    name  = "work_mem"
    value = "16384" # 16MB query workspace
  }

  # Connection tuning
  parameter {
    name  = "max_connections"
    value = "1000"
  }

  # Security and auditing parameters
  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "rds.force_ssl"
    value = "1" # Force SSL encrypted client connections
  }
}

# KMS Key for DB Storage Encryption at Rest
resource "aws_kms_key" "db_kms" {
  description             = "KMS Encryption Key for RDS Storage"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "${var.environment}-db-kms-key"
    Environment = var.environment
  }
}

# Primary Multi-AZ PostgreSQL Database Instance
resource "aws_db_instance" "db_primary" {
  identifier                  = "${var.environment}-db-primary"
  engine                      = "postgres"
  engine_version              = "15.4"
  instance_class              = var.db_instance_class
  allocated_storage           = var.db_allocated_storage
  max_allocated_storage       = 1000            # Allow auto-scaling database disk size up to 1TB
  storage_type                = "gp3"
  db_name                     = var.db_name
  username                    = var.db_username
  password                    = var.db_password
  port                        = 5432
  
  # Network & Security association
  multi_az                    = true # Provision standby instance in secondary AZ
  db_subnet_group_name        = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  publicly_accessible         = false # Isolated from public internet

  # Storage Encryption
  storage_encrypted           = true
  kms_key_id                  = aws_kms_key.db_kms.arn

  # Backups and maintenance policies
  backup_retention_period     = 30 # Retain backups for 30 days
  backup_window               = "03:00-04:00" # Midnight maintenance and snapshots
  copy_tags_to_snapshot       = true
  deletion_protection         = true # Prevent accidental DB deletion
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.environment}-db-primary-final-snapshot"

  # Performance insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7 # 7 days retention

  parameter_group_name        = aws_db_parameter_group.pg_params.name

  tags = {
    Name        = "${var.environment}-database-primary"
    Environment = var.environment
  }
}
