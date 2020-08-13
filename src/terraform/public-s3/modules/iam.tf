# S3 Bucket Policy
data "aws_iam_policy_document" "s3_bucket_policy" {
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
