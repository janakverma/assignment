# Resource to create an S3 bucket to store the Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name

  # It is highly recommended to prevent accidental deletion of the state bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Enable versioning on the S3 bucket to allow for state recovery
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}