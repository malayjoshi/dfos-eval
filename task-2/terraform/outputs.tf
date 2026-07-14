# Terraform Outputs for SaaS Infrastructure Reference

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the provisioned VPC"
}

output "public_subnets" {
  value       = [for s in aws_subnet.public : s.id]
  description = "IDs of the public subnets"
}

output "private_subnets" {
  value       = [for s in aws_subnet.private : s.id]
  description = "IDs of the private subnets"
}

output "database_subnets" {
  value       = [for s in aws_subnet.database : s.id]
  description = "IDs of the isolated database subnets"
}

output "alb_dns_name" {
  value       = aws_lb.external_alb.dns_name
  description = "The DNS name of the Application Load Balancer"
}

output "db_primary_endpoint" {
  value       = aws_db_instance.db_primary.endpoint
  description = "The database primary instance endpoint"
}

output "s3_assets_bucket" {
  value       = aws_s3_bucket.app_assets.id
  description = "The name of the app assets S3 bucket"
}

output "s3_backups_bucket" {
  value       = aws_s3_bucket.backups.id
  description = "The name of the backups S3 bucket"
}
