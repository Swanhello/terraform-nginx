## Control Plane

resource "aws_security_group" "control_plane" {
  name_prefix = "eks_control_plane_"
  vpc_id      = aws_vpc.vpc.id
}

# Ingress
resource "aws_security_group_rule" "ingress_nodes_to_control_plane" {
  description              = "Allow pods to communicate with the cluster API Server"
  security_group_id        = aws_security_group.control_plane.id
  type                     = "ingress"
  source_security_group_id = aws_security_group.nodes.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
}

# Egress

resource "aws_security_group_rule" "egress_control_plane_to_nodes" {
  description              = "Allow the cluster control pane to communicate with worker Kubelet and pods"
  security_group_id        = aws_security_group.control_plane.id
  type                     = "egress"
  source_security_group_id = aws_security_group.nodes.id
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
}

// Security group for Pods that allows inbound traffic from 0.0.0.0/0 on 80.
resource "aws_security_group" "external_pods" {
  name_prefix = "eks_cluster_pods_external_"
  description = "Security group for pods serving HTTP/s behind public NLBs"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "ingress_nodes_to_pods" {
  description              = "Allow all ingress from nodes to pods"
  security_group_id        = aws_security_group.external_pods.id
  type                     = "ingress"
  source_security_group_id = aws_security_group.nodes.id
  from_port                = -1
  to_port                  = 65535
  protocol                 = -1
}

resource "aws_security_group_rule" "ingress_pods_http" {
  description       = "Allow inbound http traffic"
  security_group_id = aws_security_group.external_pods.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

resource "aws_security_group_rule" "ingress_pods_to_self" {
  description              = "Allow all ingress from pods to self"
  security_group_id        = aws_security_group.external_pods.id
  type                     = "ingress"
  source_security_group_id = aws_security_group.external_pods.id
  from_port                = -1
  to_port                  = 65535
  protocol                 = -1
}

resource "aws_security_group_rule" "egress_pods_to_nodes" {
  description              = "Allow all egress from pods to nodes"
  security_group_id        = aws_security_group.external_pods.id
  type                     = "egress"
  source_security_group_id = aws_security_group.nodes.id
  from_port                = -1
  to_port                  = 65535
  protocol                 = -1
}

resource "aws_security_group_rule" "egress_pods_to_self" {
  description              = "Allow all egress from pods to self"
  security_group_id        = aws_security_group.external_pods.id
  type                     = "egress"
  source_security_group_id = aws_security_group.external_pods.id
  from_port                = -1
  to_port                  = 65535
  protocol                 = -1
}

## Cluster Nodes

resource "aws_security_group" "nodes" {
  name_prefix = "eks_cluster_nodes_"
  vpc_id      = aws_vpc.vpc.id
}

# Ingress

resource "aws_security_group_rule" "ingress_control_plane_to_nodes" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control panel"
  security_group_id        = aws_security_group.nodes.id
  type                     = "ingress"
  source_security_group_id = aws_security_group.control_plane.id
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "ingress_nodes_to_self" {
  description              = "Allow nodes to communicate with each other"
  security_group_id        = aws_security_group.nodes.id
  type                     = "ingress"
  source_security_group_id = aws_security_group.nodes.id
  from_port                = -1
  to_port                  = 65535
  protocol                 = -1
}

resource "aws_security_group_rule" "ingress_from_external_pods" {
  description              = "Allow traffic from external SG pods"
  security_group_id        = aws_security_group.nodes.id
  type                     = "ingress"
  source_security_group_id = aws_security_group.external_pods.id
  from_port                = -1
  to_port                  = 65535
  protocol                 = -1
}

resource "aws_security_group_rule" "ingress_http" {
  description       = "Allow inbound http traffic"
  security_group_id = aws_security_group.nodes.id
  type              = "ingress"
  cidr_blocks       = aws_vpc.vpc.cidr_blocks
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

# Egress

resource "aws_security_group_rule" "egress_nodes_to_self" {
  description              = "Allow nodes to communicate with each other"
  security_group_id        = aws_security_group.nodes.id
  type                     = "egress"
  source_security_group_id = aws_security_group.nodes.id
  from_port                = -1
  to_port                  = 65535
  protocol                 = -1
}

resource "aws_security_group_rule" "egress_nodes_to_control_plane" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  security_group_id        = aws_security_group.nodes.id
  type                     = "egress"
  source_security_group_id = aws_security_group.control_plane.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "egress_nodes_to_any_53" {
  description       = "Allow worker nodes and pods to do DNS lookups"
  security_group_id = aws_security_group.nodes.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
}

resource "aws_security_group_rule" "egress_nodes_to_any_123" {
  description       = "Allow worker nodes and pods to do NTP sync"
  security_group_id = aws_security_group.nodes.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
}

resource "aws_security_group_rule" "egress_nodes_to_any_80" {
  description       = "Allow worker nodes and pods to communicate with all HTTP"
  security_group_id = aws_security_group.nodes.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

resource "aws_security_group_rule" "egress_nodes_to_any_443" {
  description       = "Allow worker nodes and pods to communicate with all HTTPS"
  security_group_id = aws_security_group.nodes.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}
