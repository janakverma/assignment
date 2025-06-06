terraform {
  backend "s3" {
    bucket = "your-unique-s3-bucket-name" # Replace with your S3 bucket name from variables.tf
    key    = "eks/cluster/b2cloud-assignment/terraform.tfstate"
    region = "eu-north-1"

    # Enable S3-native state locking. This removes the need for a DynamoDB table.
    use_lockfile = true

    # It's still best practice to encrypt the state file at rest
    encrypt = true
  }
}