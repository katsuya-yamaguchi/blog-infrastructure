## Set Up
1.ソースをCloneする。  
```
$ git clone https://github.com/katsuya-yamaguchi/blog-infrastructure.git
```

2.AWSクレデンシャル情報を環境変数に設定する。
```
export AWS_ACCESS_KEY_ID=[アクセスキー]
export AWS_SECRET_ACCESS_KEY=[シークレットキー]
export REGION=[リージョン]
```

3.Dockerイメージを作成する。
```
$ cd ./blog-infrastructure
$ docker-compose build
```

4.Dockerコンテナに起動して接続する。
```
$ docker-compose run --rm app /bin/bash
root@81f213a342b4:/var/tmp#             ←コンテナに接続できる。
```

5.Terraformを実行する。
```
# cd /infra/terraform/[対象のディレクトリ]
# terraform init   ←初期化
# terraform plan   ←コードの検証
# terraform apply  ←コードの実行
```

※注意点  
各`main.tf`では、AssumeRoleしてTerraformを実行するための処理が記載されています。もし、AssumeRoleが不要でしたらコメントアウトして下さい。
```
provider "aws" {
  region = "ap-northeast-1"

  ######## この部分。#############
  # assume_role {
  #   role_arn     = "arn:aws:iam::XXXXXXXXXX:role/SystemAdmin"
  # }
  ##############################
}

terraform {
  required_version = "0.12.24"
  backend "s3" {
    bucket   = "tfstate.mini-schna.com"
    region   = "ap-northeast-1"
    key      = "blog/public-s3.tfstate"
    encrypt  = true

    ######## この部分。#############
    # role_arn = "arn:aws:iam::XXXXXXXXXX:role/SystemAdmin"
    ##############################
  }
}

module "aws" {
  source = "./modules"
}
```
