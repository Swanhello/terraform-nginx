resource "aws_autoscaling_group" "eks_node_asg" {
  name                      = "eks-cluster-nodes"
  max_size                  = var.eks_asg_node_max
  min_size                  = var.eks_asg_node_min
  vpc_zone_identifier       = [aws_subnet.private_subnet.id]

  launch_template {
    id      = aws_launch_template.eks_node
    version = aws_launch_template.eks_node.latest_version
  }
}
