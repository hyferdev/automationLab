# /terraform/gwlb.tf
# Defines the Gateway Load Balancer and its related components.

resource "aws_lb" "security_gwlb" {
  name               = "${var.project_name}-${var.environment}-gwlb"
  internal           = false
  load_balancer_type = "gateway"
  subnets = [
    module.vpc["security"].private_subnet_ids[0],
    module.vpc["security"].private_subnet_ids[1]
  ]

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-gwlb"
  })
}

# --- Target Group for Firewalls ---
resource "aws_lb_target_group" "paloalto_tg" {
  name        = "${var.project_name}-${var.environment}-paloalto-tg"
  port        = 6081 # GENEVE protocol port
  protocol    = "GENEVE"
  vpc_id      = module.vpc["security"].vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = "443"
  }
}

# --- Target Group Attachments ---
resource "aws_lb_target_group_attachment" "paloalto_attachments" {
  for_each = aws_instance.paloalto

  target_group_arn = aws_lb_target_group.paloalto_tg.arn
  target_id        = each.value.id
}


# --- VPC Endpoint Service ---
resource "aws_vpc_endpoint_service" "gwlb_service" {
  gateway_load_balancer_arns = [aws_lb.security_gwlb.arn]
  acceptance_required        = false

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-gwlb-service"
  })
}

# --- VPC Endpoints in Security VPC ---
# These are the actual entry points for traffic.
resource "aws_vpc_endpoint" "gwlb_endpoints" {
  for_each = toset(var.availability_zones)

  vpc_id              = module.vpc["security"].vpc_id
  service_name        = aws_vpc_endpoint_service.gwlb_service.service_name
  vpc_endpoint_type   = "GatewayLoadBalancer"
  subnet_ids          = [module.vpc["security"].gwlb_endpoint_subnet_ids_by_az[each.key]]

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-${var.environment}-gwlb-endpoint-${each.key}"
  })
}
