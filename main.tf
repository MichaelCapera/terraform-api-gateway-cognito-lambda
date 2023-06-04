# main.tf

provider "aws" {
  region = "us-east-1"  # Actualiza con tu región deseada
}

resource "aws_api_gateway_rest_api" "example_api" {
  name        = "example_api"
  description = "Example API"
}

resource "aws_api_gateway_authorizer" "example_authorizer" {
  name          = "example-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  type          = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns = [var.cognito_user_arn]
}

resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.example_authorizer.id
}

resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example_api.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.example_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"
}
