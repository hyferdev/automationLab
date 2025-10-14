# /terraform/bootstrap.tf
# Creates the S3 bucket and objects for Palo Alto bootstrapping.

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

# --- Initial Configuration File ---
# This file sets the initial admin password on first boot.
resource "aws_s3_object" "init_cfg" {
  bucket  = aws_s3_bucket.bootstrap_bucket.id
  key     = "config/init-cfg.txt"
  content = templatefile("${path.module}/init-cfg.tpl", {
    initial_password = var.panos_initial_admin_password
  })
}

# --- Placeholder Bootstrap XML ---
# This file is still required by the bootstrap process, but we can leave it
# mostly empty as the main configuration will be done by the panos provider.
resource "aws_s3_object" "bootstrap_xml" {
  bucket  = aws_s3_bucket.bootstrap_bucket.id
  key     = "config/bootstrap.xml"
  content = <<-EOT
    <?xml version="1.0"?>
    <config version="11.1.0" urldb="paloaltonetworks">
      <mgt-config>
      </mgt-config>
    </config>
  EOT
}

