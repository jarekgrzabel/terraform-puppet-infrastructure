data "aws_iam_policy_document" "puppetmaster_assumerole" {
  statement {
    sid    = "AssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "puppetmaster_ssm_access" {
  statement {
    sid    = "AllowSSMAccessToPuppetSSHKey"
    effect = "Allow"

    actions = [
      "ssm:Get*",
    ]

    resources = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/puppet*"]
  }
}

resource "aws_iam_role" "puppetmaster_role" {
  name               = "puppetmaster-role"
  assume_role_policy = "${data.aws_iam_policy_document.puppetmaster_assumerole.json}"
}

resource "aws_iam_policy" "puppetmaster_ssm_ro_policy" {
  name        = "puppetmaster-ssm-ro-policy"
  description = "Policy to access SSM"
  policy      = "${data.aws_iam_policy_document.puppetmaster_ssm_access.json}"
}

resource "aws_iam_role_policy_attachment" "puppetmaster_asm_role_attachment" {
  role       = "${aws_iam_role.puppetmaster_role.name}"
  policy_arn = "${aws_iam_policy.puppetmaster_ssm_ro_policy.arn}"
}

resource "aws_iam_instance_profile" "puppetmaster_profile" {
  name = "puppetmaster-instance-role"
  role = "${aws_iam_role.puppetmaster_role.name}"
}
