variable "subnet_id" {}
variable "sg_22_80" {}
variable "public_key" {}
variable "dbhost" {}
variable "alb_dns" {}
variable "cache_redis_host" {}
variable "dns_name_lb" {}
#=========================================================================================
output "ec2_id" {
  value = aws_instance.ec2.id
}
#=========================================================================================
resource "aws_instance" "ec2" {
  ami           = "ami-0c1c30571d2dae5c9"
  instance_type = "t2.micro"
  tags = {
    Name = "wordpress"
  }
  key_name                    = "aws_key"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.sg_22_80]
  associate_public_ip_address = true
  user_data = templatefile("./ec2/install_script.sh", {
    dbname         = "devprojdb"
    dbuser         = "dbuser"
    dbpass         = "dbpassword"
    dbhost         = var.dbhost
    cache_host     = var.cache_redis_host
    alb_dns        = var.dns_name_lb
    company_name   = "abz.agency"
    wp_admin       = "artem"
    wp_password    = "21012000zxc"
    wp_admin_email = "artembrigaz@gmail.com"


  })

  metadata_options {
    http_endpoint = "enabled"  # Enable the IMDSv2 endpoint
    http_tokens   = "required" # Require the use of IMDSv2 tokens
  }
}
#=========================================================================================
resource "aws_key_pair" "keys" {
  key_name   = "aws_key"
  public_key = var.public_key
}
#=========================================================================================
