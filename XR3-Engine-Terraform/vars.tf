variable "AWS_ACCESS_KEY" {
  default = 
}

variable "AWS_SECRET_KEY" {
  default =
}

variable "AWS_REGION" {
  default = "Your AWS Account Region"
}

variable "db_root_password" {
  description = "the db root password"
  type = "string"
  default = "************"
  sensitive = true
}
