###############################################
# ログ格納用バケット
###############################################
resource "aws_s3_bucket" "logging" {
  bucket = "logging.mini-schna.com"
  policy = data.aws_iam_policy_document.logging_bucket.json ## iam.tfで設定したポリシーを使用。
  force_destroy = true
  versioning {
    enabled    = true
    mfa_delete = false
  }

  ## オブジェクトのライフサイクル設定。
  lifecycle_rule {
    id      = "assets"
    enabled = true

    ## オブジェクトの保存期限。
    expiration {
      days = "365" ## 1年
    }

    ## 現在のオブジェクトの移行設定。
    transition {
      ## オブジェクトが作成されてから移行するまでの日数。
      days          = "93" ## 3ヶ月
      storage_class = "STANDARD_IA"
    }

    ## オブジェクトの以前のバージョンの保存期限。
    noncurrent_version_expiration {
      days = "1095" ## 3年
    }

    ## 古いのオブジェクトの移行設定。
    noncurrent_version_transition {
      ## オブジェクトが古いバージョンになってから移行するまでの日数。
      days          = "365" ## 1年
      storage_class = "GLACIER"
    }
  }

  request_payer = "BucketOwner"
}

# S3 Public Access Block
## パブリックアクセスはしないため全て有効にする。
resource "aws_s3_bucket_public_access_block" "logging" {
  bucket                  = aws_s3_bucket.logging.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
