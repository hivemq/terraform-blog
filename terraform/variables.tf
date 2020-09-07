variable "access_key" {
  default = ""
}
variable "secret_key" {
  default = ""
}
variable "region" {
  default = "eu-west-1"
}
variable "s3_bucket" {
  default = "hivemq-install"
}
variable "instance_type" {
  default = "t3.medium"
}

variable "source_dir" {
  default = "/tmp/build/put/git"
}
variable "restricted_cidr" {
  type = list
  default = [ "0.0.0.0/0" ]
}