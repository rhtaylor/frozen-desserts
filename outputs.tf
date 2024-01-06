output "alb_hostname" {
  value = aws_alb.main.dns_name
}

output "name_servers" {
  description = "DNS Name servers used for the zone"
  value       = aws_route53_zone.pskdomain_name.name_servers
}

output "hosted_zone_id" {
  description = "The hosted zone ID"
  value       = aws_route53_zone.pskdomain_name.zone_id
}