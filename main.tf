resource "aws_apigatewayv2_api" "http_api" {
  name          = var.api_name
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
  }
}

resource "aws_apigatewayv2_integration" "get_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.get_integration_lambda_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "post_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.post_integration_lambda_arn
  payload_format_version = "2.0"
}

# resource "aws_apigatewayv2_authorizer" "jwt_authorizer" {
#   api_id           = aws_apigatewayv2_api.http_api.id
#   name             = "jwt-authorizer"
#   authorizer_type  = "JWT"
#   identity_sources = ["$request.header.Authorization"]
#   jwt_configuration {
#     issuer   = "https://idp.ku0.de/realms/plungestreak"
#     audience = ["plungestreak"]
#   }
# }

resource "aws_apigatewayv2_route" "default_get_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.get_lambda_integration.id}"
  # authorization_type = "JWT"
  # authorizer_id = aws_apigatewayv2_authorizer.jwt_authorizer.id
}

resource "aws_apigatewayv2_route" "default_post_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.post_lambda_integration.id}"
  # authorization_type = "JWT"
  # authorizer_id = aws_apigatewayv2_authorizer.jwt_authorizer.id
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

output "api_url" {
  value = aws_apigatewayv2_stage.default_stage.invoke_url
}

resource "aws_lambda_permission" "get_lambda_permission" {
  statement_id  = "Allow${var.api_name}ApiGateway-${var.get_integration_lambda_name}"
  action        = "lambda:InvokeFunction"
  function_name = var.get_integration_lambda_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*/{proxy+}"
}

resource "aws_lambda_permission" "post_lambda_permission" {
  statement_id  = "Allow${var.api_name}ApiGateway-${var.post_integration_lambda_name}"
  action        = "lambda:InvokeFunction"
  function_name = var.post_integration_lambda_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*/{proxy+}"
}
