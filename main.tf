terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_api_gateway_rest_api" "aws_trigger" {

  name = "aws_trigger"

  # endpoint_configuration {
  #   types = ["REGIONAL"]
  # }
}

resource "aws_api_gateway_deployment" "aws_trigger" {
  rest_api_id = aws_api_gateway_rest_api.aws_trigger.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.aws_trigger.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "aws_trigger" {
  deployment_id = aws_api_gateway_deployment.aws_trigger.id
  rest_api_id   = aws_api_gateway_rest_api.aws_trigger.id
  stage_name    = "aws_trigger"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "resource"
  parent_id   = aws_api_gateway_rest_api.aws_trigger.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.aws_trigger.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.aws_trigger.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration
resource "aws_api_gateway_integration" "thursday_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.aws_trigger.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.thursday_lambda.arn}/invocations"
  type = "AWS"                           # Documentation not clear
  integration_http_method = "POST"       # Not documented
  # request_templates = {                  # Not documented
  #   "application/json" = "${file("api_gateway_body_mapping.template")}"
  # }
}

resource "aws_lambda_function" "thursday_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "artifact/main.zip"
  function_name = "thursday_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("thursday_function.zip"))}"
  source_code_hash = filebase64sha256("artifact/main.zip")

  runtime = "go1.x"

  # environment {
  #   variables = {
  #     foo = "bar"
  #   }
  # }
}
