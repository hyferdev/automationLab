# /terraform/gwlb.tf
# This file defines the Gateway Load Balancer and its components.

# --- Gateway Load Balancer ---
resource "aws_lb" "security_gwlb" {
  name               = "${var.project_name}-security-gwlb"
  internal           = false
  load_balancer_type = "gateway"
  subnets = [
    module.vpc["security"].appliance_subnet_ids[0],
    module.vpc["security"].appliance_subnet_ids[1]
  ]

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-security-gwlb"
  })
}

# --- Target Group for FortiGates ---
resource "aws_lb_target_group" "fortigate_tg" {
  name        = "${var.project_name}-fortigate-tg"
  port        = 6081
  protocol    = "GENEVE"
  vpc_id      = module.vpc["security"].vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = "6081" # FortiGate health check port
    interval = 30
    timeout  = 10
  }

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-fortigate-tg"
  })
}

# --- GWLB Listener ---
resource "aws_lb_listener" "fortigate_listener" {
  load_balancer_arn = aws_lb.security_gwlb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fortigate_tg.arn
  }
}

# --- VPC Endpoint Service ---
# This allows other VPCs (via the TGW) to connect to our GWLB.
resource "aws_vpc_endpoint_service" "gwlb_service" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.security_gwlb.arn]

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-gwlb-service"
  })
}

# --- VPC Endpoints for the GWLB Service ---
# These are the actual "interfaces" in our security VPC that will receive traffic.
resource "aws_vpc_endpoint" "gwlb_endpoints" {
  for_each = toset(var.availability_zones)

  vpc_id              = module.vpc["security"].vpc_id
  service_name        = aws_vpc_endpoint_service.gwlb_service.service_name
  vpc_endpoint_type   = "GatewayLoadBalancer"
  subnet_ids = [
    module.vpc["security"].gwlb_endpoint_subnet_ids[index(var.availability_zones, each.key)]
  ]

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-gwlb-endpoint-${each.key}"
  })
}

