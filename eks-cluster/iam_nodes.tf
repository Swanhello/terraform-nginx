resource "aws_iam_role" "eks_cluster_node" {
  name = "eks-cluster-node"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "eks_sts_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    resources = [
        "arn:aws:iam::<aws-account-id>:role/eks-cluster"
    ]
  }
}

resource "aws_iam_policy" "eks-sts-assume-role" {
  name   = "eks-cluster-sts-assume-role"
  policy = data.aws_iam_policy_document.eks_sts_policy_document.json
}

resource "aws_iam_policy_policy_attachment" "cluster_AmazonEKSWrokerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_cluster_node.name
}

resource "aws_iam_policy_policy_attachment" "cluster_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_cluster_node.name
}

resource "aws_iam_policy_policy_attachment" "cluster_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_cluster_node.name
}

resource "aws_iam_policy_policy_attachment" "eks_sts_assume_role_policy_attachment" {
  policy_arn = aws_iam_policy.eks-sts-assume-role.arn
  role       = aws_iam_role.eks_cluster_node.name
}

resource "aws_iam_policy_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_cluster_node.name
}

resource "aws_iam_instance_profile" "eks_cluster_node" {
  name = "eks-cluster-node-instance-profile"
  role = aws_iam_role.eks_cluster_node.name
}
