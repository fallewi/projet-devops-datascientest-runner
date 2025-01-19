###############################################################################
# VPC
###############################################################################

output "public_ip" {
  value = module.ec2-instance.public_ip
  description = "L'adresse IP publique de l'instance"
}
