variable "consul_acm_domain" {}
variable "vault_acm_domain" {}
variable "nomad_acm_domain" {}
variable "vault_alb_port" {}
variable "vault_alb_protocol" {}
variable "vault_alb_ssl_policy" { default = "ELBSecurityPolicy-2016-08" }
variable "consul_alb_port" {}
variable "consul_alb_protocol" {}
variable "consul_alb_ssl_policy" { default = "ELBSecurityPolicy-2016-08" }
variable "nomad_alb_port" {}
variable "nomad_alb_protocol" {}
variable "nomad_alb_ssl_policy" { default = "ELBSecurityPolicy-2016-08" }
variable "region" {}
variable "priv_subnets" { type = "list" }
variable "pub_subnets" { type = "list" }
variable "key_name" {}
variable "ami_id" {}
variable "vault_asg_max" {}
variable "vault_asg_min" {}
variable "vault_asg_desired" {}
variable "vault_userdata" {}
variable "vault_instance_type" {}
variable "vault_sgs" { type = "list" }
variable "vault_iam_instance_profile" {}
variable "consul_asg_max" {}
variable "consul_asg_min" {}
variable "consul_asg_desired" {}
variable "consul_userdata" {}
variable "consul_instance_type" {}
variable "consul_sgs" { type = "list" }
variable "consul_iam_instance_profile" {}
variable "nomad_asg_max" {}
variable "nomad_asg_min" {}
variable "nomad_asg_desired" {}
variable "nomad_userdata" {}
variable "nomad_instance_type" {}
variable "nomad_sgs" { type = "list" }
variable "nomad_iam_instance_profile" {}
variable "datacenter" {}
variable "consul_server_join_tag_value" {}
variable "consul_server_join_tag_key" {}
variable "vpc_id" {}
variable "nomad_tg_port" {}
variable "nomad_tg_protocol" {}
variable "nomad_hc_interval" {}
variable "nomad_hc_path" {}
variable "nomad_hc_port" {}
variable "nomad_hc_protocol" {}
variable "nomad_hc_timeout" {}
variable "nomad_hc_healthy_threshold" {}
variable "nomad_hc_unhealthy_threshold" {}
variable "nomad_matcher" { default = "200"}
variable "consul_tg_port" {}
variable "consul_tg_protocol" {}
variable "consul_hc_interval" {}
variable "consul_hc_path" {}
variable "consul_hc_port" {}
variable "consul_hc_protocol" {}
variable "consul_hc_timeout" {}
variable "consul_hc_healthy_threshold" {}
variable "consul_hc_unhealthy_threshold" {}
variable "consul_matcher" { default = "200"}
variable "vault_tg_port" {}
variable "vault_tg_protocol" {}
variable "vault_hc_interval" {}
variable "vault_hc_path" {}
variable "vault_hc_port" {}
variable "vault_hc_protocol" {}
variable "vault_hc_timeout" {}
variable "vault_hc_healthy_threshold" {}
variable "vault_hc_unhealthy_threshold" {}
variable "vault_matcher" { default = "200"}
variable "vault_endpoint_url" {}
variable "consul_endpoint_url" {}
variable "nomad_endpoint_url" {}
variable "r53_zone_id" {}
variable "nomad_client_count" {}
variable "nomad_client_instance_type" {}
variable "nomad_client_userdata" {}
