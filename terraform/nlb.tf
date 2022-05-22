module "nlb" {
  source             = "terraform-aws-modules/alb/aws"
  name               = "my-nlb"
  version            = "6.4.0"
  load_balancer_type = "network"

  vpc_id = module.vpc.vpc_id
	subnets = module.vpc.public_subnets

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name_prefix          = "http"
      backend_protocol     = "TCP"
      backend_port         = 80
      target_type          = "instance"
      proxy_protocol_v2    = false
      deregistration_delay = 300
      health_check = {
        enabled             = true
        protocol            = "TCP"
        port                = 80
        interval            = 30
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }
    },
  ]
}
