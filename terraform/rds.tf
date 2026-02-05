# DBサブネットグループ (2つのプライベートサブネットを束ねる)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project}-db-subnet-group"
  }
}

# RDSインスタンス本体
resource "aws_db_instance" "main" {
  identifier             = "${var.project}-db"
  allocated_storage      = 20
  storage_type           = "gp3"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro" # 無料枠対象
  db_name                = "wordpress"
  username               = var.db_username # variables.tfとtfvarsに定義が必要
  password               = var.db_password # variables.tfとtfvarsに定義が必要
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true # ハンズオン後の削除をスムーズにするため
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.project}-rds"
  }
}