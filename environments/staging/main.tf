
# Data Sources
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# IAM Role & Instance Profile
resource "aws_iam_role" "staging_ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

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
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.staging_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.staging_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy" "ecr_read_only" {
  name = "${var.project_name}-${var.environment}-ecr-ro"
  role = aws_iam_role.staging_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "staging_profile" {
  name = "${var.project_name}-${var.environment}-profile"
  role = aws_iam_role.staging_ec2_role.name
}

# Security Group
resource "aws_security_group" "staging_sg" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for staging EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP inbound"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH inbound"
  }


  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound (SSM, ECR, API)"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound (yum/dnf)"
  }

  tags = var.tags
}

# EC2 Instance
resource "aws_instance" "staging" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = var.staging_subnet_id != "" ? var.staging_subnet_id : data.aws_subnets.default_public.ids[0]
  vpc_security_group_ids      = [aws_security_group.staging_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.staging_profile.name
  associate_public_ip_address = true
  key_name                    = "name"
  
  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    project_name = var.project_name
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ec2"
  })
}

module "github-oidc" {
  source                  = "../../modules/github-oidc"
  project_name            = var.project_name
  environment             = var.environment
  create_github_oidc_role = true
  github_org              = "nithingowdahm87"
  github_repository       = "Octa-Byte-AI-Application"
  github_branch           = "stage"
  github_environment      = "staging"
}


