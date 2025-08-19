# /terraform/fortigate.tf

# Data source to find the latest FortiGate AMI
data "aws_ami" "fortigate" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWS*"]
  }
}

resource "aws_instance" "fortigate" {
  for_each = toset(var.availability_zones)

  ami           = data.aws_ami.fortigate.id
  instance_type = "c5.large" # Recommended size for FortiGate
  key_name      = var.ssh_key_name
  subnet_id     = module.vpc["security"].appliance_subnet_ids[index(var.availability_zones, each.key)]
  
  # Disable source/destination check is critical for firewall appliances
  source_dest_check = false

  tags = merge(var.standard_tags, var.project_tags, {
    Name = "${var.project_name}-fortigate-${each.key}"
  })
}

# Attach each FortiGate instance to the GWLB Target Group
resource "aws_lb_target_group_attachment" "fortigate_attachment" {
  for_each = aws_instance.fortigate

  target_group_arn = aws_lb_target_group.fortigate_tg.arn
  target_id        = each.value.id
}

