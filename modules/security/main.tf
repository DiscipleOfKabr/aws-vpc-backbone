resource "aws_security_group" "private_sg" {
  name        = "${var.env_name}-private-sg"
  description = "Allow inbound traffic only from public sec. group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "${var.env_name}-private-sg"
  }
}



resource "aws_security_group" "alb_sg" {
  name        = "${var.env_name}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id




  ingress {

    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.env_name}-alb-sg" }

}


# iam infrastructure set-up


resource "aws_iam_role" "backend_role" {

  name = "${var.env_name}-backend-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {

        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.backend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "backend_profile" {
  name = "${var.env_name}-backend-profile"
  role = aws_iam_role.backend_role.name
}

