###############################################
# 静的サイト公開用バケット
###############################################
resource "aws_s3_bucket" "mini_schna_com" {
  bucket = "mini-schna.com"
  policy = data.aws_iam_policy_document.mini_schna_com_bucket.json ## iam.tfで設定したポリシーを使用。

  ## バケットの削除設定。
  force_destroy = false ## バケットの中にオブジェクトが入っている場合にTerraformからバケットを削除できないようにする。

  ## Webサイト設定。
  website {
    ## バケットにアクセスした時にデフォルトで表示されるコンテンツを設定。
    index_document = "index.html"
  }

  ## オブジェクトのバージョン管理設定。
  versioning {
    enabled    = true
    mfa_delete = false ## オブジェクトへのアクセスにMFA(多段階認証)を使用しない。
  }

  ## バケットの料金を誰が支払うか設定。
  request_payer = "BucketOwner" ## 通常通り所有者が支払う。
}

resource "aws_s3_bucket_public_access_block" "mini_schna_com" {
  bucket                  = aws_s3_bucket.mini_schna_com.bucket
  block_public_acls       = true
  block_public_policy     = false ## バケットポリシーで制御したいため無効にする。
  ignore_public_acls      = true
  restrict_public_buckets = false ## バケットポリシーで制御したいため無効にする。
}

###############################################
# CloudFrontのアクセスログ格納用バケット
###############################################
resource "aws_s3_bucket" "cloudfront_logging" {
  bucket = "cloudfront-logging.mini-schna.com"
  policy = data.aws_iam_policy_document.cloudfront_logging_bucket.json ## iam.tfで設定したポリシーを使用。
  force_destroy = false
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
resource "aws_s3_bucket_public_access_block" "cloudfront_logging" {
  bucket                  = aws_s3_bucket.cloudfront_logging.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
