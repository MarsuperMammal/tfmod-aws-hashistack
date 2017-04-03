variable "acm_domain" {}
variable "alb_port" {}
variable "alb_protocol" {}
variable "ssl_policy" { default = "ELBSecurityPolicy-2016-08" }
variable "region" {}
variable "priv_subnets" { type = "list" }
variable "pub_subnets" { type = "list" }
variable "asg_max" {}
variable "asg_min" {}
variable "asg_desired" {}
variable "key_name" {}
variable "app_name" {}
variable "ami_id" {}
variable "userdata" {}
variable "instance_type" {}
variable "asg_sgs" { type = "list" }
variable "datacenter" {}
variable "consul_server_join_tag_value" {}
variable "consul_server_join_tag_key" {}
variable "iam_instance_profile" {}
variable "port" {}
variable "protocol" {}
variable "vpc_id" {}
variable "hc_interval" {}
variable "hc_path" {}
variable "hc_port" {}
variable "hc_protocol" {}
variable "hc_timeout" {}
variable "hc_healthy_threshold" {}
variable "hc_unhealthy_threshold" {}
variable "matcher" { default = "200"}
variable "endpoint_url" {}
variable "r53_zone_id" {}

output "asg" { value = "${aws_autoscaling_group.asg.id}" }
