data "aws_acm_certificate" "vaultcert" {
  domain = "${var.vault_acm_domain}"
}

data "aws_acm_certificate" "consulcert" {
  domain = "${var.consul_acm_domain}"
}

data "aws_acm_certificate" "nomadcert" {
  domain = "${var.nomad_acm_domain}"
}

resource "aws_route53_record" "vaultr53" {
  zone_id = "${var.r53_zone_id}"
  name = "${var.vault_endpoint_url}"
  type = "A"

  alias {
    name = "${aws_alb.alb.dns_name}"
    zone_id = "${aws_alb.alb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "consulr53" {
  zone_id = "${var.r53_zone_id}"
  name = "${var.consul_endpoint_url}"
  type = "A"

  alias {
    name = "${aws_alb.alb.dns_name}"
    zone_id = "${aws_alb.alb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "nomadr53" {
  zone_id = "${var.r53_zone_id}"
  name = "${var.nomad_endpoint_url}"
  type = "A"

  alias {
    name = "${aws_alb.alb.dns_name}"
    zone_id = "${aws_alb.alb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_alb" "alb" {
  name_prefix = "hashi"
  internal = false
  security_groups = ["${var.nomad_sgs}","${var.consul_sgs}","${var.vault_sgs}"]
  subnets = ["${var.pub_subnets}"]
}

resource "aws_alb_target_group" "vaulttg" {
  name = "vault"
  port = "${var.vault_tg_port}"
  protocol = "${var.vault_tg_protocol}"
  vpc_id = "${var.vpc_id}"
  health_check {
    interval = "${var.vault_hc_interval}"
    path = "${var.vault_hc_path}"
    port = "${var.vault_hc_port}"
    protocol = "${var.vault_hc_protocol}"
    timeout = "${var.vault_hc_timeout}"
    healthy_threshold = "${var.vault_hc_healthy_threshold}"
    unhealthy_threshold = "${var.vault_hc_unhealthy_threshold}"
    matcher = "${var.vault_matcher}"
  }
}

resource "aws_alb_target_group" "consultg" {
  name = "consul"
  port = "${var.consul_tg_port}"
  protocol = "${var.consul_tg_protocol}"
  vpc_id = "${var.vpc_id}"
  health_check {
    interval = "${var.consul_hc_interval}"
    path = "${var.consul_hc_path}"
    port = "${var.consul_hc_port}"
    protocol = "${var.consul_hc_protocol}"
    timeout = "${var.consul_hc_timeout}"
    healthy_threshold = "${var.consul_hc_healthy_threshold}"
    unhealthy_threshold = "${var.consul_hc_unhealthy_threshold}"
    matcher = "${var.consul_matcher}"
  }
}

resource "aws_alb_target_group" "nomadtg" {
  name = "nomad"
  port = "${var.nomad_tg_port}"
  protocol = "${var.nomad_tg_protocol}"
  vpc_id = "${var.vpc_id}"
  health_check {
    interval = "${var.nomad_hc_interval}"
    path = "${var.nomad_hc_path}"
    port = "${var.nomad_hc_port}"
    protocol = "${var.nomad_hc_protocol}"
    timeout = "${var.nomad_hc_timeout}"
    healthy_threshold = "${var.nomad_hc_healthy_threshold}"
    unhealthy_threshold = "${var.nomad_hc_unhealthy_threshold}"
    matcher = "${var.nomad_matcher}"
  }
}

resource "aws_alb_listener" "vaultalbl" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port = "${var.vault_alb_port}"
  protocol = "${var.vault_alb_protocol}"
  ssl_policy = "${var.vault_alb_ssl_policy}"
  certificate_arn = "${data.aws_acm_certificate.vaultcert.arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.vaulttg.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener" "consulalbl" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port = "${var.consul_alb_port}"
  protocol = "${var.consul_alb_protocol}"
  ssl_policy = "${var.consul_alb_ssl_policy}"
  certificate_arn = "${data.aws_acm_certificate.consulcert.arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.consultg.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener" "nomadalbl" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port = "${var.nomad_alb_port}"
  protocol = "${var.nomad_alb_protocol}"
  ssl_policy = "${var.nomad_alb_ssl_policy}"
  certificate_arn = "${data.aws_acm_certificate.nomadcert.arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.nomadtg.arn}"
    type = "forward"
  }
}

resource "aws_launch_configuration" "vaultlc" {
  name_prefix = "vault"
  image_id = "${var.ami_id}"
  instance_type = "${var.vault_instance_type}"
  user_data = "${var.vault_userdata}"
  iam_instance_profile = "${var.vault_iam_instance_profile}"
  security_groups = ["${var.vault_sgs}"]
  key_name = "${var.key_name}"

  root_block_device {
    volume_size = 30
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "vaultasg" {
  name = "${aws_launch_configuration.vaultlc.name}"
  launch_configuration  = "${aws_launch_configuration.vaultlc.name}"
  vpc_zone_identifier = ["${var.priv_subnets}"]
  max_size = "${var.vault_asg_max}"
  min_size = "${var.vault_asg_min}"
  desired_capacity = "${var.vault_asg_desired}"
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  target_group_arns = ["${aws_alb_target_group.vaulttg.arn}"]
  tag {
    key = "Name"
    value = "vault"
    propagate_at_launch = true
  }
  tag {
    key = "${var.consul_server_join_tag_key}"
    value = "${var.consul_server_join_tag_value}"
    propagate_at_launch = true
  }
  depends_on = ["aws_autoscaling_group.consulasg"]
}

resource "aws_launch_configuration" "nomadlc" {
  name_prefix = "nomad"
  image_id = "${var.ami_id}"
  instance_type = "${var.nomad_instance_type}"
  user_data = "${var.nomad_userdata}"
  iam_instance_profile = "${var.nomad_iam_instance_profile}"
  security_groups = ["${var.nomad_sgs}"]
  key_name = "${var.key_name}"

  root_block_device {
    volume_size = 30
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nomadasg" {
  name = "${aws_launch_configuration.nomadlc.name}"
  launch_configuration  = "${aws_launch_configuration.nomadlc.name}"
  vpc_zone_identifier = ["${var.priv_subnets}"]
  max_size = "${var.nomad_asg_max}"
  min_size = "${var.nomad_asg_min}"
  desired_capacity = "${var.nomad_asg_desired}"
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  target_group_arns = ["${aws_alb_target_group.nomadtg.arn}"]
  tag {
    key = "Name"
    value = "nomad"
    propagate_at_launch = true
  }
  tag {
    key = "${var.consul_server_join_tag_key}"
    value = "${var.consul_server_join_tag_value}"
    propagate_at_launch = true
  }
  depends_on = ["aws_autoscaling_group.consulasg"]
}

resource "aws_launch_configuration" "consullc" {
  name_prefix = "consul"
  image_id = "${var.ami_id}"
  instance_type = "${var.consul_instance_type}"
  user_data = "${var.consul_userdata}"
  iam_instance_profile = "${var.consul_iam_instance_profile}"
  security_groups = ["${var.consul_sgs}"]
  key_name = "${var.key_name}"

  root_block_device {
    volume_size = 30
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "consulasg" {
  name = "${aws_launch_configuration.consullc.name}"
  launch_configuration  = "${aws_launch_configuration.consullc.name}"
  vpc_zone_identifier = ["${var.priv_subnets}"]
  max_size = "${var.consul_asg_max}"
  min_size = "${var.consul_asg_min}"
  desired_capacity = "${var.consul_asg_desired}"
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  target_group_arns = ["${aws_alb_target_group.consultg.arn}"]
  tag {
    key = "Name"
    value = "consul"
    propagate_at_launch = true
  }
  tag {
    key = "${var.consul_server_join_tag_key}"
    value = "${var.consul_server_join_tag_value}"
    propagate_at_launch = true
  }
}

resource "aws_instance" "nomad-client" {
  count = "${var.nomad_client_count}"
  ami_id = "${var.ami_id}"
  instance_type = "${var.nomad_client_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${var.nomad_sgs}"]
  iam_instance_profile = "${var.nomad_iam_instance_profile}"
  subnet_id = "${var.priv_subnets[count.index]}"
  user_data = "${var.nomad_client_userdata}"
  root_block_device {
    volume_size = 30
    delete_on_termination = true
  }
  tag {
    key = "Name"
    value = "nomad-client"
    propagate_at_launch = true
  }
  tag {
    key = "${var.consul_server_join_tag_key}"
    value = "${var.consul_server_join_tag_value}"
    propagate_at_launch = true
  }
}