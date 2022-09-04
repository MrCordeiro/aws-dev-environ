variable "host_os" {
  type        = string
  default     = "linux"
  description = "OS of the host machine: linux, windows"
}

variable "host_ip" {
  type        = string
  description = "IP of the host machine"
}

variable "ami_name" {
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  description = "AMI name"
}

variable "ami_owner_id" {
  type        = string
  default     = "099720109477"
  description = "AMI owner ID"
}