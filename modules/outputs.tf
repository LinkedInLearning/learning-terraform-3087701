output "environment_url" {
  value = module.alb.dns_name
}

output "vpc_id" {
  value = module.web_vpc.vpc_id
}

output "autoscaling_group_name" {
  value = module.autoscaling.autoscaling_group_name
}