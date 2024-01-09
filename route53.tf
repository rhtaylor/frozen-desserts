# resource "aws_route53_zone" "domain_name" {
#   name = var.domainName
# }


# resource "aws_route53_record" "domain_name" {
#   zone_id = aws_route53_zone.domain_name.zone_id
  
#   name    = var.domainName
#   type    = "A"
#   alias {
#     name                   = aws_alb.main.dns_name
#     zone_id                = aws_alb.main.zone_id
#     evaluate_target_health = true
#   }
# }