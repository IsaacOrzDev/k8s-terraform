data "aws_route53_zone" "public" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_acm_certificate" "api" {
  domain_name       = "${var.sub_domain_name}.${var.domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "api_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.public.zone_id
}


resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for record in aws_route53_record.api_validation : record.fqdn]
}

resource "aws_lb_listener_certificate" "listener_certificate" {
  listener_arn    = aws_lb_listener.lb_listener.arn
  certificate_arn = aws_acm_certificate.api.arn
}


output "alb_https_url" {
  value = "https://${aws_acm_certificate.api.domain_name}"
}
