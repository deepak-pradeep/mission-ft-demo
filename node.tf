data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name        = "${var.cluster_name}-worker-role"
  description = "Worker Role for cluster ${var.cluster_name}"
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in merge(
    {
      AmazonEKSWorkerNodePolicy          = ""
      AmazonEC2ContainerRegistryReadOnly = ""
    }
  ) : k => v }

  policy_arn = each.value
  role       = aws_iam_role.this.name
}