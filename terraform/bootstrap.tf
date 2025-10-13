# /terraform/bootstrap.tf
# Creates the S3 bucket required by the Palo Alto IAM role.

resource "aws_s3_bucket" "bootstrap_bucket" {
  bucket = lower("${var.project_name}-${var.environment}-pa-bootstrap")

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-pa-bootstrap-bucket"
  })
}

resource "aws_s3_bucket_public_access_block" "bootstrap_bucket_pab" {
  bucket = aws_s3_bucket.bootstrap_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}