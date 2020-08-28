##################################################
# security group (ALB)
##################################################
resource "aws_security_group" "alb" {
  name                   = "alb"
  vpc_id                 = aws_vpc.main.id
  revoke_rules_on_delete = false
}

# インターネットからALBに対するHTTP通信(ポート80)を許可するSG
resource "aws_security_group_rule" "alb_permit_from_internet_http" {
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "permit from internet for http."
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
}

# インターネットからALBに対するHTTPS通信(ポート80)を許可するSG
resource "aws_security_group_rule" "alb_permit_from_internet_https" {
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "permit from internet for https."
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
}

##################################################
# security group (web)
##################################################
resource "aws_security_group" "web" {
  name                   = "web"
  vpc_id                 = aws_vpc.main.id
  revoke_rules_on_delete = false
}

# ALBからのHTTP通信(ポート80)を許可するSG
resource "aws_security_group_rule" "web_permit_from_alb" {
  security_group_id        = aws_security_group.web.id
  source_security_group_id = aws_security_group.alb.id
  description              = "permit from alb."
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "80"
  to_port                  = "80"
}
