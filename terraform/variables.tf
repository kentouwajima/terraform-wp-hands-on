variable "project" {
  description = "プロジェクト名"
  type        = string
  default     = "wp-handson"
}

# 後のステップで使うDB用変数も定義だけしておきます
variable "db_username" {
  description = "RDS user"
  type        = string
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}