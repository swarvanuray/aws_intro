variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
variable "ssh_key_name" {
  type        = string
  default     = "nginx"
  description = "ssh key name to be created in EC2 and store in ~/.ssh folder"
}
variable "env" {
  type        = string
  default     = "dev"
  description = "environment e.g. dev|qa|prod"
}



