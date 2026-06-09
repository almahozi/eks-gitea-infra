resource "aws_security_group" "main" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-rds-sg"
})
}

resource "aws_vpc_security_group_ingress_rule" "allow_eks_traffic" {
  security_group_id = aws_security_group.main.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = var.cluster_security_group_id
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.cluster_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-rds-subnet-group"
})
}

resource "aws_db_instance" "main" {
  identifier        = "${var.cluster_name}-rds"
  instance_class = var.db_instance_class
  engine = "mysql"
  engine_version = "8.0"
  db_name = var.db_name
  username = var.db_username
  password_wo = var.db_password

  allocated_storage = 20

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot = true
  multi_az            = false

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-rds"
  })
}