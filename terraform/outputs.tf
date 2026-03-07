output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static site."
  value       = aws_s3_bucket.site.bucket
}

output "s3_website_endpoint" {
  description = "Direct S3 website endpoint (before CloudFront)."
  value       = aws_s3_bucket_website_configuration.site.website_endpoint
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain you can use for the site."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "visitor_api_url" {
  description = "Invoke URL for the visitor counter API."
  value       = "${aws_apigatewayv2_api.visitor_api.api_endpoint}/visitors"
}


