# Storage Resources (S3 Buckets, Lifecycle Policies, Public Access Blocks)

# 1. Private S3 Bucket for general application assets
resource "aws_s3_bucket" "app_assets" {
  bucket        = "${var.environment}-saas-app-assets-12345" # Append random suffix
  force_destroy = false

  tags = {
    Name        = "Application Assets S3"
    Environment = var.environment
  }
}

# 2. Private S3 Bucket for backups (Velero, DB snapshots, logs)
resource "aws_s3_bucket" "backups" {
  bucket        = "${var.environment}-saas-backups-12345"
  force_destroy = false

  tags = {
    Name        = "Cluster Backups S3"
    Environment = var.environment
  }
}

# Enable Versioning for both buckets (Disaster recovery protection)
resource "aws_s3_bucket_versioning" "assets_versioning" {
  bucket = aws_s3_bucket.app_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "backups_versioning" {
  bucket = aws_s3_bucket.backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Default Server-Side Encryption (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "assets_encryption" {
  bucket = aws_s3_bucket.app_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups_encryption" {
  bucket = aws_s3_bucket.backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block Public Access strictly (Security best practice)
resource "aws_s3_bucket_public_access_block" "block_assets_public" {
  bucket = aws_s3_bucket.app_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "block_backups_public" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for backups: Transition old files to cheap Glacier storage
resource "aws_s3_bucket_lifecycle_configuration" "backups_lifecycle" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "archive-old-backups"
    status = "Enabled"

    # Transition noncurrent versions to Glacier after 30 days
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    # Permanent deletion of noncurrent versions after 90 days
    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    # Transition current objects to Glacier after 60 days
    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    # Auto expire current objects after 180 days
    expiration {
      days = 180
    }
  }
}
