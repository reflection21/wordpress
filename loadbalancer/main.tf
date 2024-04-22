variable "sg_lb" {}
variable "public_subnets" {}
variable "target_group" {}
variable "ec2_id" {}
#=========================================================================================
output "name_lb" {
  value = aws_lb.lb.dns_name
}
output "zone_lb" {
  value = aws_lb.lb.zone_id
}
output "lb_dns_name" {
  value = aws_lb.lb.dns_name
}
#=========================================================================================
resource "aws_lb" "lb" {
  name                       = "loadbalancer"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.sg_lb]
  subnets                    = var.public_subnets
  enable_deletion_protection = false
  tags = {
    Name = "loadbalancer"
  }
}
#=========================================================================================
resource "aws_lb_target_group_attachment" "lb_attach" {
  target_group_arn = var.target_group
  target_id        = var.ec2_id
  port             = 80

}
#=========================================================================================
resource "aws_lb_listener" "port_80" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = var.target_group
  }
}
#=========================================================================================
