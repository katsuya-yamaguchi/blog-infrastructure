# 変数
variable "bucket_name" {
  default     = "mini-schna.com"
  description = "s3 bucket name."
}

# S3 Bucket
resource "aws_s3_bucket" "mini_schna_com" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.s3_bucket_policy.json ## iam.tfで設定したポリシーを使用。

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

# S3 Public Access Block
resource "aws_s3_bucket_public_access_block" "mini_schna_com" {
  bucket                  = aws_s3_bucket.mini_schna_com.bucket
  block_public_acls       = true
  block_public_policy     = false ## バケットポリシーで制御したいため無効にする。
  ignore_public_acls      = true
  restrict_public_buckets = false ## バケットポリシーで制御したいため無効にする。
}
