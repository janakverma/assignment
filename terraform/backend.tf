terraform {
  backend "s3" {
    bucket = "b2cloud-assignment-01"
    key    = "eks/cluster/b2cloud-assignment/terraform.tfstate"
    region = "eu-north-1"

    # Enable S3-native state locking. This removes the need for a DynamoDB table.
    use_lockfile = true

    # It's still best practice to encrypt the state file at rest
    encrypt = true
  }
}