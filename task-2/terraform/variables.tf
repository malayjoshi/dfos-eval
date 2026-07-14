# Global Variables for SaaS Infrastructure
variable "aws_region" {
  type        = string
  description = "The AWS Region to deploy infrastructure"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "production"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (ALB & NAT Gateways)"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets (Application instances)"
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for isolated database subnets"
  default     = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}

variable "compute_instance_type" {
  type        = string
  description = "EC2 Instance type for application hosts"
  default     = "t3.medium"
}

variable "db_instance_class" {
  type        = string
  description = "RDS DB Instance class"
  default     = "db.r6g.xlarge"
}

variable "db_allocated_storage" {
  type        = number
  description = "Initial storage allocated for database in GB"
  default     = 100
}

variable "db_name" {
  type        = string
  description = "Name of the default SaaS database"
  default     = "saas_prod"
}

variable "db_username" {
  type        = string
  description = "Admin username for the database"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Admin password for the database"
  sensitive   = true
}
