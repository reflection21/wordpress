variable "subnet_group_ecr" {}
variable "sg_ecr" {}
#=========================================================================================
output "host_redis" {
  value = aws_elasticache_cluster.test.cache_nodes[0].address
}
#=========================================================================================
resource "aws_elasticache_subnet_group" "subnets" {
  name       = "my-subnet-group"
  subnet_ids = var.subnet_group_ecr
}
#=========================================================================================
resource "aws_elasticache_cluster" "test" {
  cluster_id         = "wordpress"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.subnets.name
  security_group_ids = [var.sg_ecr]
}
#=========================================================================================