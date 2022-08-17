
variable "region" {
  type = string
}

variable "env" {
  default = "dev"
}

variable "application" {
  default = "open-url"
}

variable "open_browser_url" {
  type = string  
}

variable "count_replicas" {
  type = number
  default = 1
}
