
variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "env" {
  default = "dev"
}

variable "application" {
  default = "open-url"
}

variable "ecr_repository_name" {
  default = "dev/open-url"
}
