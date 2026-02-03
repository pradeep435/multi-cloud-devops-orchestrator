provider "aws" {
  region = "ap-south-1"
}

# -------------------------------
# Security Group
# -------------------------------
resource "aws_security_group" "app_sg" {
  name        = "multicloud-app-sg"
  description = "Allow SSH and app traffic"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application access"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "multicloud-app-sg"
  }
}

# -------------------------------
# EC2 Instance
# -------------------------------
resource "aws_instance" "app_server" {
  ami           = "ami-0f58b397bc5c1f2e8" # Amazon Linux 2 (ap-south-1)
  instance_type = "t3.micro"
  key_name      = "multicloud-key"

  # ✅ CORRECT way for VPC
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              yum install git -y
              cd /home/ec2-user
              git clone https://github.com/pradeep435/multi-cloud-devops-orchestrator.git
              cd multi-cloud-devops-orchestrator
              docker build -t multi-cloud-app .
              docker run -d -p 5000:5000 multi-cloud-app
              EOF

  tags = {
    Name = "MultiCloud-App-Server"
  }
}
