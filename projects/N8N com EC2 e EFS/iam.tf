data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}

resource "aws_iam_role" "ec2_profile" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = "${local.project_name}-ec2-role"
}

resource "aws_iam_role_policy_attachment" "session_manager" {
  role       = aws_iam_role.ec2_profile.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" # AWS managed policy for SSM Access
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.project_name}-ec2-profile"
  role = aws_iam_role.ec2_profile.name
}