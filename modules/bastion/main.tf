
data "aws_ami" "amazon_linux_2023" {
  count       = var.create_bastion_host ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_iam_role" "bastion_role" {
  count = var.create_bastion_host ? 1 : 0
  name  = "${var.project_name}-${var.environment}-bastion-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  count      = var.create_bastion_host ? 1 : 0
  role       = aws_iam_role.bastion_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  count = var.create_bastion_host ? 1 : 0
  name  = "${var.project_name}-${var.environment}-bastion-profile"
  role  = aws_iam_role.bastion_role[0].name
}

resource "aws_instance" "bastion" {
  count                  = var.create_bastion_host ? 1 : 0
  ami                    = data.aws_ami.amazon_linux_2023[0].id
  instance_type          = var.bastion_instance_type
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.bastion_sg_id]
  iam_instance_profile   = aws_iam_instance_profile.bastion_profile[0].name

  # No public IP mapped implicitly or explicitly beyond what's allowed.
  # The subnet may assign one if map_public_ip_on_launch is true, but it's false.

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-bastion" })
}
