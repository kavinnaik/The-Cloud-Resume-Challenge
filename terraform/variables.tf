variable "project_name" {
  description = "Short name for this project (used for tagging and resource naming)."
  type        = string
  default     = "cloud-resume-portfolio"
}

variable "aws_region" {
  description = "AWS region to deploy the S3 bucket in."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)."
  type        = string
  default     = "prod"
}

variable "bucket_name" {
  description = "Optional custom S3 bucket name. Leave empty to let Terraform generate a name."
  type        = string
  default     = ""
}

variable "visitor_table_name" {
  description = "DynamoDB table name for visitor counter."
  type        = string
  default     = "cloud-resume-visitor-counter"
}

