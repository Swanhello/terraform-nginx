variable "eks_node_container_runtime" {
  type    = string
  default = "containerd"
}

variable "eks_asg_node_max" {
  type    = number
  default = 5
}

variable "eks_asg_node_min" {
  type    = number
  default = 2
}
