resource "aws_cloudfront_distribution" "s3_distribution" {
  # distribution用のCNAME。
  # Route53でCloudFrontのエイリアスを設定する場合、この値とレコードが等しくなる必要がある。
  aliases = ["mini-schna.com"]

  # Errorレスポンスのカスタマイズ設定。
  custom_error_response {
    error_caching_min_ttl = 300 # デフォルトの5分間を明示的に指定。
    error_code            = 500 # カスタマイズしたいエラーコードを指定する。
    response_code         = 200 # Viewerに返したいコードを指定する。
    response_page_path    = "/custom_404.html"
  }

  # キャッシュのデフォルト設定。
  default_cache_behavior {
    allowed_methods = ["HEAD", "OPTIONS", "GET", "PUT", "POST", "DELETE", "PATCH"] # CloudFrontで許可するメソッド。
    cached_methods  = ["HEAD", "OPTIONS", "GET"]                                   # キャッシュするメソッド。
    compress        = true                                                         # 高速化のためコンテンツ圧縮(gzip)を許可する。
    # Cache-Control or Expires がリクエストのヘッダーに無い時のデフォルトのTTL。
    # デフォルトの1日を明示的に指定。
    default_ttl = 86400

    max_ttl = 31536000 # デフォルトの365日を明示的に指定。
    min_ttl = 0        # デフォルトの0sを明示的に指定。

    # 転送する時にCookie等の扱い方の設定。
    forwarded_values {
      query_string = false # クエリ文字の設定。今回使用しないため無効。
      cookies {
        forward = "all" # 全てのCookieを転送する。
        # whitelisted_names = [] # whitelistの場合に設定する必要がある。
      }
    }

    # Lambdaで処理したい場合に設定する項目。まだ使用しないため無効。
    # lambda_function_association {
    #   event_type = ""
    #   lambda_arn = ""
    # }

    # MS Smooth Streaming形式のメディアは使用しないた
    smooth_streaming = false

    target_origin_id = aws_s3_bucket.mini_schna_com.id ## S3バケットをオリジンとする。

    # 信頼された署名者を指定する設定。
    trusted_signers = []

    viewer_protocol_policy = "redirect-to-https" # HTTPS通信のみ許可する。
  }

  default_root_object = "index.html"

  enabled         = true
  is_ipv6_enabled = false   # ipv6は使用しないため無効。
  http_version    = "http2" # デフォルトのhttp2を明示的に指定。

  # アクセスログ設定。
  logging_config {
    bucket          = aws_s3_bucket.cloudfront_logging.bucket_domain_name
    include_cookies = true # Cookieもアクセスログに含めたいため有効。
    prefix          = "cloudfront/"
  }

  # 優先度を設定したキャッシュ設定。Precedence 0。
  # ordered_cache_behavior {
  #   forwarded_values {
  #     query_string = false
  #     cookies {
  #       forward = ""
  #     }
  #   }
  #   allowed_methods        = ["GET", "PUT", "POST", "DELETE"] # CloudFrontで許可するメソッド。
  #   cached_methods         = ["GET", "PUT", "POST", "DELETE"] # キャッシュするメソッド。
  #   path_pattern           = "/"
  #   target_origin_id       = var.origin_bucket_id # S3バケットをオリジンとする。
  #   viewer_protocol_policy = "redirect-to-https"  # HTTPS通信のみ許可する。
  # }

  origin {
    domain_name = aws_s3_bucket.mini_schna_com.bucket_domain_name
    origin_id   = aws_s3_bucket.mini_schna_com.id
    # カスタムヘッダー。
    # custom_header {
    #   name = ""
    #   value = ""
    # }
    # origin_path = "/" # オリジンのパスは変更しないため無効。

    # OriginにアクセスするためのIAM設定。
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.mini_schna.cloudfront_access_identity_path
    }
  }

  # Originフェイルオーバーを行うために必要なOriginグループの設定。
  # 今回は使用しないため無効。
  # origin_group {
  #   origin_id = ""
  #   failover_criteria {
  #     status_codes = []
  #   }
  #   member {
  #     origin_id = ""
  #   }
  # }

  # 価格クラスの設定。
  price_class = "PriceClass_All" # レイテンシーのみに基づいて使用するロケーションを決める方法を採用。

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # locations        = [] # blacklist(or whitelist)の対象を設定していく。
    }
  }

  # SSL証明書の設定。
  viewer_certificate {
    cloudfront_default_certificate = false # ACMで作成した証明書を使用するため無効。
    acm_certificate_arn            = "arn:aws:acm:us-east-1:XXXXXXXXXXX:certificate/XXXXXXXXXXXXXXXXXX"
    minimum_protocol_version       = "TLSv1.2_2019" # SSLの最小バージョン。AWSの推奨値を採用。
    # SNI(名前ベース)のSSL機能を使用する。
    # https://aws.amazon.com/jp/cloudfront/custom-ssl-domains/
    ssl_support_method = "sni-only"
  }

  retain_on_delete = false # TerraformでCloudFrontを削除したいため無効。

  # ディストリビューションのステータスが「InProgress」→「Deployed」に変わることを待つかどうかの設定。
  wait_for_deployment = true
}

resource "aws_cloudfront_origin_access_identity" "mini_schna" {
  comment = "blog"
}