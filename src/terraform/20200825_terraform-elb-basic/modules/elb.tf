variable "acm_certificate_arn" {
  default = "arn:aws:acm:ap-northeast-1:XXXXXXXXXXXXXXXXXX:certificate/XXXXXXXXXXXXXXXXXX"
}

##################################################
# Target group
##################################################
resource "aws_lb_target_group" "mini_schna_com" {
  name        = "mini-schna-com"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  # 登録解除を実行するまでの待機時間。
  deregistration_delay = 300 # 処理中のリクエストの完了するのを待つためにデフォルト値を採用。

  # 登録された後にリクエストを開始する猶予時間
  slow_start = 0 # 登録されたらすぐに開始してよいので無効。

  load_balancing_algorithm_type = "round_robin" # ラウンドロビンで平均的にリクエストを分散。

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400 # 要件が決まっていないのでとりあえず1日を設定。
    enabled         = true
  }

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port" # トラフィックを受信するポートを使用。デフォルト。
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }
}


##################################################
# Listener
##################################################
# HTTPS通信のためのリスナー
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.mini_schna_com.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mini_schna_com.arn
  }
}

# Listener: HTTPをHTTPSにリダイレクトするためのリスナー
resource "aws_lb_listener" "http_redirect_to_https" {
  load_balancer_arn = aws_lb.mini_schna_com.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

##################################################
# LB
##################################################
resource "aws_lb" "mini_schna_com" {
  name               = "mini-schna-com"
  internal           = false # 内部で使用しないため無効。
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  access_logs {
    bucket  = aws_s3_bucket.logging.bucket
    prefix  = "elb"
    enabled = true
  }

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id
  ]

  idle_timeout               = 60    # デフォルトの60秒を設定。
  enable_deletion_protection = false # Terraformで削除したいため無効。
  enable_http2               = true
  ip_address_type            = "ipv4" # ipv6は使用しないためipv4を指定。
}
