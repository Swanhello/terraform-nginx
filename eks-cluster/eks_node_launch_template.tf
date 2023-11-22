locals {
  node-userdata = <<USERDATA
#!/bin/bash -xe

/etc/eks/bootstrap.sh eks-cluster --container-runtime ${var.eks_node_container_runtime}

USERDATA
}

resource "aws_launch_template" "eks_node" {
  name_prefix   = "eks-cluster-node"
  image_id      = "amazon-eks-node-1.28-v20231116"
  instance_type = "m6a.large"
  key_name      = "instance-key"
  user_data     = filebase64(local.node-userdata)

  network_interfaces {
    delete_on_termination = true
    associate_public_ip_address = false
    security_groups = aws_security_group.nodes.id
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_cluster_node.name
  }

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = "100"
      volume_type = "gp3"
      encrypted   = true
    }
  }

  update_default_version = true
}
