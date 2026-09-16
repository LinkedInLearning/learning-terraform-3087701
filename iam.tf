# Trust policy: who can assume this role (EC2 service)
data "aws_iam_policy_document" "lab_ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"] #sts stands for security token service which means this role will get temporary creds
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lab_ec2_role" {
  name               = "Lab-EC2-S3ReadOnly-Role"
  assume_role_policy = data.aws_iam_policy_document.lab_ec2_assume_role.json
}

# Permission policy: what the role can actually do
data "aws_iam_policy_document" "lab_s3_read" {
  statement {
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::tf-course-2026-example",
      "arn:aws:s3:::tf-course-2026-example/*"
    ]
  }
}

resource "aws_iam_role_policy" "lab_s3_read_policy" {
  name   = "Lab-S3ReadOnly-Policy"
  role   = aws_iam_role.lab_ec2_role.id
  policy = data.aws_iam_policy_document.lab_s3_read.json
}

# Instance profile: bridge between IAM role and EC2
resource "aws_iam_instance_profile" "lab_ec2_profile" {
  name = "Lab-EC2-InstanceProfile"
  role = aws_iam_role.lab_ec2_role.name
}
