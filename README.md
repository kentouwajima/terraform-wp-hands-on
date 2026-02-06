# Terraform WordPress Hands-on Project

AWS上にスケーラブルでセキュアなWordPress環境をTerraformで構築し、ローカル環境からサイトを移行したプロジェクトの記録です。

## 🏛️ アーキテクチャ構成
本プロジェクトでは、以下のAWSリソースをTerraformでコード化（IaC）しています。

- **Network**: VPC, Public Subnets (2-AZ), Internet Gateway
- **Compute**: EC2 (Amazon Linux 2023)
- **Database**: RDS for MySQL
- **Load Balancer**: Application Load Balancer (ALB)
- **Security**: Security Groups, IAM Roles (for SSM)



---

## 🚀 実施した主なタスク

### 1. インフラの自動構築 (Terraform)
- Network、EC2、RDS、ALBの一連のリソースを定義し、コマンド一発で環境を再現可能にしました。
- 最小権限の原則に基づき、セキュリティグループを適切に分離しました。

### 2. WordPressの移行
- ローカル環境のファイル一式とデータベース（SQL）をEC2へ転送・インポート。
- `sed` コマンドを用いて、データベース内のURLを一括置換（localhost → ALB DNS）。
- Apacheの `AllowOverride` 設定および `.htaccess` の適正化によるパーマリンク（下層ページ）の正常化。

### 3. セキュリティと運用性の向上 (SSM導入)
- インバウンドのSSH（22番ポート）を完全に閉鎖。
- **AWS Systems Manager (SSM) Session Manager** を導入し、IAM権限ベースでのセキュアなターミナル接続を実現。

---

## 🛠️ 移行・構築手順詳細

### 1. ファイルの展開と配置
```bash
# ファイルの展開と配置
unzip wordpress.zip -d temp_wp
sudo cp -r temp_wp/* /var/www/html/
sudo chown -R apache:apache /var/www/html/
rm -rf temp_wp wordpress.zip

```

### 2. データベースのセットアップ

```bash
# RDSでのDB作成
mysql -h [RDS_ENDPOINT] -u [USER] -p -e "CREATE DATABASE wordpress2;"

# SQL内のURL置換とインポート
sed -i 's|http://localhost:8888|http://[ALB_DNS_NAME]|g' ~/wordpress.sql
mysql -h [RDS_ENDPOINT] -u [USER] -p wordpress2 < ~/wordpress.sql

```

### 3. WordPress設定 (`wp-config.php`)

```php
// 接続情報とURL強制指定
define('DB_NAME', 'wordpress2');
define('DB_USER', '[RDS_USER]');
define('DB_PASSWORD', '[RDS_PASSWORD]');
define('DB_HOST', '[RDS_ENDPOINT]');
define('WP_HOME', 'http://[ALB_DNS_NAME]');
define('WP_SITEURL', 'http://[ALB_DNS_NAME]');

```

### 4. Apache設定

`/etc/httpd/conf/httpd.conf` 内の `<Directory "/var/www/html">` セクションで `AllowOverride All` を設定し、Apacheを再起動。

---

## 🔑 接続・運用方法

SSM接続が有効なため、以下のコマンドでセキュアにログイン可能です。

```bash
aws ssm start-session --target [INSTANCE_ID]

# ログイン後の初期操作
sudo su - ec2-user
/bin/bash

```

## 📝 今後の展望

* [ ] Route53による独自ドメインの設定
* [ ] ACMによるHTTPS(SSL)化
* [ ] S3へのメディアファイル移行（ステートレス化）

```