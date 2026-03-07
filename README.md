# Kavin Naik – Cloud Resume Challenge Portfolio

This repository contains my Cloud / DevOps portfolio website built for the **Cloud Resume Challenge**.  
The site is a static single‑page application hosted on **Amazon S3**, fronted by **CloudFront**, with a **serverless visitor counter** powered by **API Gateway + Lambda + DynamoDB**, all managed via **Terraform** and deployed using **GitHub Actions CI/CD**.

## Tech Stack

- **Frontend**: HTML, CSS, JavaScript (single‑page, LaunchNow‑style layout)
- **Cloud**: AWS S3, CloudFront, Route 53 (optional/custom domain)
- **Backend**: AWS Lambda (Python), API Gateway HTTP API, DynamoDB
- **IaC**: Terraform
- **CI/CD**: GitHub Actions

## Project Structure

- `index.html` – main single‑page portfolio
- `assets/css/style.css` – styling and layout
- `assets/js/main.js` – animations, navigation, visitor counter fetch
- `lambda/visitor-counter/index.py` – Lambda function for visitor counter
- `terraform/` – Terraform configuration for S3, CloudFront, DynamoDB, Lambda, API Gateway
- `.github/workflows/deploy.yml` – CI/CD pipeline

## Local Preview

```bash
cd /path/to/Portfolio
# Option 1: simple static server
python -m http.server 8000
# then open http://localhost:8000 in the browser
```

The visitor counter will show `--` locally unless you configure the live API URL in `index.html`.

## Infrastructure with Terraform

Terraform configuration lives in the `terraform/` directory.

### One‑time setup

1. Install:
   - Terraform
   - AWS CLI
2. Configure AWS credentials:
   ```bash
   aws configure
   ```
3. From the `terraform/` folder:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```
4. Note the outputs:
   - `s3_bucket_name`
   - `cloudfront_domain_name`
   - `visitor_api_url`

### Visitor Counter Backend

The visitor counter is implemented with:

- **DynamoDB** table (`cloud-resume-visitor-counter`) with partition key `id` and attribute `visits`
- **Lambda** (`lambda/visitor-counter/index.py`) that:
  - Atomically increments `visits` for the item `{ id: "global" }`
  - Returns JSON: `{ "count": <number> }`
- **API Gateway HTTP API** with route `GET /visitors` that proxies to the Lambda

After applying Terraform, get the public URL:

```bash
cd terraform
terraform output -raw visitor_api_url
```

Then update `index.html`:

```html
<script>
  window.VISITOR_COUNT_API_URL = "https://your-api-id.execute-api.region.amazonaws.com/visitors";
</script>
```

Re‑deploy the static site to S3 for the change to take effect.

## Manual Deployment to S3

From the project root:

```bash
cd /path/to/Portfolio

# Get bucket name
cd terraform
terraform output -raw s3_bucket_name
cd ..

# Sync static files
aws s3 sync . "s3://<your-bucket-name>" \
  --exclude "terraform/*" \
  --exclude ".terraform/*" \
  --exclude ".git/*" \
  --exclude ".github/*" \
  --exclude "deploy-local.ps1" \
  --delete
```

Use the `cloudfront_domain_name` output from Terraform to access the live site via HTTPS.

## GitHub Actions CI/CD

The workflow `.github/workflows/deploy.yml` automatically:

1. Runs `terraform init` and `terraform apply` in `terraform/`
2. Reads `s3_bucket_name` from Terraform outputs
3. Syncs the repository contents to the S3 bucket

### Required GitHub secrets

In the GitHub repository settings, configure:

- `AWS_ACCESS_KEY_ID` – IAM user/programmatic access key
- `AWS_SECRET_ACCESS_KEY` – matching secret
- `AWS_REGION` – e.g. `ap-south-1`

On every push to `main`, GitHub Actions will update the infrastructure (idempotently) and deploy the latest static files.

## Cloud Resume Challenge Checklist

- **HTML/CSS/JavaScript frontend** – `index.html`, `assets/`
- **Deployed to S3 with CloudFront CDN** – provisioned by Terraform
- **Custom domain with Route 53** – can be added to `terraform/` if desired
- **Visitor counter with API Gateway, Lambda, DynamoDB** – `lambda/visitor-counter`, Terraform resources
- **Infrastructure as Code** – full stack defined in Terraform
- **Version control with Git & GitHub** – this repository
- **CI/CD pipeline** – GitHub Actions workflow `deploy.yml`


