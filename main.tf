module "ec2" {
  source = "./modules/ec2"

  instance_type     = var.instance_type
  server_name       = var.server_name
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
  availability_zone = var.availability_zone

}