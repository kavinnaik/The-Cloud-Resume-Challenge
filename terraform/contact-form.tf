data "archive_file" "contact_form" {
  type        = "zip"
  source_file = "${path.module}/../lambda/contact-form/index.py"
  output_path = "${path.module}/build/contact-form.zip"
}

resource "aws_iam_role" "contact_lambda" {
  name               = "${var.project_name}-${var.environment}-contact-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "contact_lambda_policy" {
  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
  }

  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy" "contact_lambda" {
  name   = "${var.project_name}-${var.environment}-contact-lambda-policy"
  role   = aws_iam_role.contact_lambda.id
  policy = data.aws_iam_policy_document.contact_lambda_policy.json
}

resource "aws_lambda_function" "contact_form" {
  function_name    = "${var.project_name}-${var.environment}-contact-form"
  role             = aws_iam_role.contact_lambda.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.contact_form.output_path
  source_code_hash = data.archive_file.contact_form.output_base64sha256

  environment {
    variables = {
      TO_EMAIL = "kavinnaik19@gmail.com"
    }
  }

  tags = local.common_tags
}

resource "aws_apigatewayv2_integration" "contact_integration" {
  api_id                 = aws_apigatewayv2_api.visitor_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.contact_form.arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "contact_route" {
  api_id    = aws_apigatewayv2_api.visitor_api.id
  route_key = "POST /contact"
  target    = "integrations/${aws_apigatewayv2_integration.contact_integration.id}"
}

resource "aws_lambda_permission" "contact_apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvokeContact"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*"
}

output "contact_api_url" {
  description = "Endpoint for the contact form"
  value       = "${aws_apigatewayv2_api.visitor_api.api_endpoint}/contact"
}
