module "networking" {
  source                   = "./networking"
  cidr_block_vpc           = var.cidr_block_vpc
  cidr_private_subnets     = var.cidr_private_subnets
  cidr_public_subnets      = var.cidr_public_subnets
  availability_zone        = var.availability_zone
  cidr_private_subnets_ecr = var.cidr_private_subnets_ecr
}
#=========================================================================================
module "sg" {
  source                    = "./securitygroup"
  vpc_id                    = module.networking.vpc_id
  cidr_block_public_subnets = tolist(module.networking.cidr_block_public_subnets)
}
#=========================================================================================
module "tg" {
  source = "./targetgroup"
  vpc_id = module.networking.vpc_id
  ec2_id = module.ec2.ec2_id
}
#=========================================================================================
module "lb" {
  source         = "./loadbalancer"
  sg_lb          = module.sg.sg_22_80
  public_subnets = tolist(module.networking.public_subnets_id)
  target_group   = module.tg.target_id
  ec2_id         = module.ec2.ec2_id
}
#=========================================================================================
module "rds" {
  source          = "./rdsmysql"
  subnet_group_db = tolist(module.networking.private_subnets_id)
  sg_db           = module.sg.sg_3306
}
#=========================================================================================
module "elasticache" {
  source           = "./elasticache"
  subnet_group_ecr = module.networking.private_subnet_ecr
  sg_ecr           = module.sg.sg_6379
}
#=========================================================================================
module "ec2" {
  source           = "./ec2"
  subnet_id        = tolist(module.networking.public_subnets_id)[0]
  sg_22_80         = module.sg.sg_22_80
  public_key       = var.public_key
  dbhost           = module.rds.endpoint_db
  alb_dns          = module.lb.lb_dns_name
  cache_redis_host = module.elasticache.host_redis
  dns_name_lb      = module.lb.lb_dns_name
}
#=========================================================================================
/*module "hz" {
  source          = "./hostedzone"
  aws_lb_dns_name = module.lb.name_lb
  aws_lb_zone_id  = module.lb.zone_lb
}*/



