output "api_gw_invoke_url" {
  description = "The invoke URL of the API Gateway"
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}
