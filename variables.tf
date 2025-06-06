variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "eu-north-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "b2cloud-assignment"
}

variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "b2cloud-assignment-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "172.16.0.0/16" 
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state."
  type        = string
  default     = "b2cloud-assignment"
}