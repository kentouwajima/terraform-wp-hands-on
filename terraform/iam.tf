# 1. EC2がAWSサービス（SSMなど）を呼び出すための信頼関係を定義
resource "aws_iam_role" "ec2_role" {
  name = "${var.project}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# 2. SSMに必要な標準ポリシーをロールにアタッチ
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 3. EC2インスタンスに紐付けるための「プロファイル」を作成
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}