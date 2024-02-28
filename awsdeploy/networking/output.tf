output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.app_lb.dns_name
}

output "acm_setup" {
  value = "Test this demo code by going to https://${aws_route53_record.server_route_alias.fqdn} and checking your have a valid SSL cert"
}


output "route53_dns" {
  value = "Route53 ARN ${aws_route53_zone.dns_service.arn}"
}

output "lb-dns-name" {
  value = "LB DNS Name ${aws_lb.app_lb.dns_name}"
}