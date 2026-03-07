Param(
  [string]$BucketName = ""
)

# Simple helper script to build (static) and upload the site to S3.
# This assumes you have already applied the Terraform in the ./terraform folder
# and that the AWS CLI is configured on your machine.

Write-Host "Deploying static site to S3..." -ForegroundColor Cyan

Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

if (-not (Get-Command "aws" -ErrorAction SilentlyContinue)) {
  Write-Error "AWS CLI is not installed or not on PATH. Install it from https://aws.amazon.com/cli/ and try again."
  exit 1
}

if (-not $BucketName) {
  # Try to read the bucket name from Terraform output
  if (Test-Path ".\terraform") {
    Push-Location ".\terraform"
    try {
      $BucketName = (terraform output -raw s3_bucket_name)
    } catch {
      Write-Error "Could not read bucket name from Terraform outputs. Pass -BucketName explicitly."
      Pop-Location
      exit 1
    }
    Pop-Location
  }
}

if (-not $BucketName) {
  Write-Error "No S3 bucket name provided. Use -BucketName or run Terraform and try again."
  exit 1
}

Write-Host "Using bucket: $BucketName" -ForegroundColor Green

aws s3 sync . "s3://$BucketName" `
  --exclude "terraform/*" `
  --exclude ".terraform/*" `
  --exclude ".git/*" `
  --exclude "deploy-local.ps1" `
  --delete

Write-Host "Upload complete." -ForegroundColor Green

