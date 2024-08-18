# /*Create EKS Cluster**:
#    - **Use `eksctl`**:
#      ```bash
#      eksctl create cluster \
#        --name my-cluster \
#        --region us-west-2 \
#        --vpc-public-subnets <public-subnet-id> \
#        --vpc-private-subnets <private-subnet-id> \
#        --nodegroup-name standard-workers \
#        --node-type t3.medium \
#        --nodes 2
# */


# resource "aws_eks_cluster" "my-cluster" {
#   name     = "my-cluster"
#   version  = "1.24"
#   role_arn = aws_iam_role.eks_cluster_role.arn
#   vpc_config {
#     subnet_ids = flatten([aws_subnet.private_subnet[*].id, aws_subnet.public_subnet[*].id]) # Use private subnets for the EKS cluster
#   }
#   tags = {
#     name = "my-cluster"
#   }


# }


# resource "aws_eks_node_group" "standard-workers" {
#   subnet_ids      = aws_subnet.private_subnet[*].id
#   cluster_name    = aws_eks_cluster.my-cluster.name
#   node_group_name = "standard-workers"
#   node_role_arn   = aws_iam_role.eks_worker_node.arn
#   instance_types  = ["t3.medium"]
#   ami_type        = "AL2_x86_64" # Ensure you're using the correct AMI type
#   scaling_config {
#     desired_size = 2
#     max_size     = 3
#     min_size     = 2
#   }

#   tags = {
#     name = "standard-workers"
#   }

# }


