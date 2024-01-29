resource "aws_route53_zone" "domain_name" {
  name = var.domain
}


resource "aws_route53_record" "domain_name" {
  zone_id = aws_route53_zone.domain_name.zone_id
  
  name    = var.domain
  type    = "A"
  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}


resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.domain}"
}

# cloudfront terraform - creating AWS Cloudfront distribution :
#creating Cloudfront distribution :
resource "aws_cloudfront_distribution" "cf_dist" {
  enabled             = true
  aliases             = [var.domain]
  origin {
    domain_name = aws_alb.main.dns_name
    origin_id   = aws_alb.main.dns_name
    custom_origin_config {
      http_port              = 80
      https_port             = 80
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_alb.main.dns_name
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      headers      = []
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN", "US", "CA"]
    }
  }
 
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}


resource "aws_acm_certificate" "cert" {
  domain_name       = "webmasterssolutions.co"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.example.zone_id
}