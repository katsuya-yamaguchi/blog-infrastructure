###############################################
# 静的サイト公開用バケットポリシー
###############################################
data "aws_iam_policy_document" "mini_schna_com_bucket" {
  statement {
    sid    = ""
    effect = "Allow"

    ## アクセス元の設定。
    principals {
      identifiers = ["*"] ## 誰でもアクセスできるように設定。
      type        = "*"
    }

    ## バケットに対して制御するアクションを設定する。
    actions = [
      "s3:GetObject" ## オブジェクトの読み取りアクション。
    ]

    ## アクセス先の設定。
    resources = [
      "arn:aws:s3:::mini-schna.com",  ## mini-schna.comバケットへのアクセス。
      "arn:aws:s3:::mini-schna.com/*" ## mini-schna.comバケット配下へのアクセス。
    ]
  }
}

###############################################
# CloudFrontのアクセスログ格納用バケットポリシー
###############################################
data "aws_iam_policy_document" "cloudfront_logging_bucket" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::cloudfront-logging.mini-schna.com",
      "arn:aws:s3:::cloudfront-logging.mini-schna.com/*"
    ]
  }
}
