terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: configure a remote backend (e.g. S3) for Terraform state
  # backend "s3" {
  #   bucket = "your-tf-state-bucket"
  #   key    = "cloud-resume/terraform.tfstate"
  #   region = "ap-south-1"
  # }
}

provider "aws" {
  region = var.aws_region
}

