# 最新の Amazon Linux 2023 AMI を取得
data "aws_ami" "amzn_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# EC2インスタンス
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amzn_linux_2023.id
  instance_type          = "t3.micro"
  key_name               = "kentouwajima" # 作成済みのキーペア名
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = aws_subnet.public[0].id # 1a側のパブリックサブネット
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  # 起動時にApacheとPHP(WordPress用)をインストール
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd php php-mysqlnd
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "${var.project}-ec2"
  }
}