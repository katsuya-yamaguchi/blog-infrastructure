# ELBアカウントIDを取得するために使用
data "aws_elb_service_account" "main" {}

###############################################
# ログ格納用バケットポリシー
###############################################
data "aws_iam_policy_document" "logging_bucket" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = [
        data.aws_elb_service_account.main.arn
      ]
      type        = "AWS"
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::logging.mini-schna.com",
      "arn:aws:s3:::logging.mini-schna.com/*"
    ]
  }
}
