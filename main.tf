data "aws_acm_certificate" "cert" {
  domain = "${var.acm_domain}"
}

resource "aws_route53_record" "r53" {
  zone_id = "${var.r53_zone_id}"
  name = "${var.endpoint_url}"
  type = "A"

  alias {
    name = "${aws_alb.alb.dns_name}"
    zone_id = "${aws_alb.alb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_alb" "alb" {
  name_prefix = "${var.app_name}"
  internal = false
  security_groups = ["${var.asg_sgs}}"]
  subnets = ["${var.pub_subnets}}"]
}

resource "aws_alb_target_group" "albtg" {
  name = "${var.app_name}"
  port = "${var.port}"
  protocol = "${var.protocol}"
  vpc_id = "${var.vpc_id}"
  health_check {
    interval = "${var.hc_interval}"
    path = "${var.hc_path}"
    port = "${var.hc_port}"
    protocol = "${var.hc_protocol}"
    timeout = "${var.hc_timeout}"
    healthy_threshold = "${var.hc_healthy_threshold}"
    unhealthy_threshold = "${var.hc_unhealthy_threshold}"
    matcher = "${var.matcher}"
  }
}

resource "aws_alb_listener" "albl" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port = "${var.alb_port}"
  protocol = "${var.alb_protocol}"
  ssl_policy = "${var.ssl_policy}"
  certificate_arn = "${aws_acm_certificate.cert.arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.albtg.arn}"
    type = "forward"
  }
}

resource "aws_launch_configuration" "lc" {
  name_prefix = "${var.app_name}"
  image_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  user_data = "${var.userdata}"
  iam_instance_profile = "${var.iam_instance_profile}"
  security_groups = ["${var.asg_sgs}"]
  key_name = "${var.key_name}"

  root_block_device {
    volume_size = 30
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${aws_launch_configuration.lc.name}"
  launch_configuration  = "${aws_launch_configuration.lc.name}"
  vpc_zone_identifier = ["${var.priv_subnets}"]
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  target_group_arns = ["${aws_alb_target_group.albtg.arn}"]
  tag {
    key = "Name"
    value = "${var.app_name}"
    propagate_at_launch = true
  }
  tag {
    key = "${var.consul_server_join_tag_key}"
    value = "${var.consul_server_join_tag_value}"
    propagate_at_launch = true
  }
}