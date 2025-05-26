# Định nghĩa các biến cho REPO_URL, COMMIT_HASH, RDS_ENDPOINT_URL, VPC_ID và SUBNET_ID
variable "repo_url" {
  type    = string
  default = "https://github.com/longngo192/cmp-cicd.git"
}

variable "commit_hash" {
  type    = string
  default = ""
}

variable "rds_endpoint_url" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "iam_instance_profile" {
  type    = string
  default = "" # Thay bằng tên IAM instance profile có quyền SSM
}

# security app server
variable "security_group_id" {
  type    = string
  default = ""
}


# Cấu hình builder amazon-ebs để tạo AMI
source "amazon-ebs" "backend" {
  ami_name      = "backend-ami-{{timestamp}}"
  source_ami_filter {
    filters = {
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
  }
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami    = "ami-0953476d60561c955"
  ssh_username  = "ec2-user"
  ssh_timeout   = "10m"
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  security_group_ids = [var.security_group_id]
  associate_public_ip_address = false

  # Sử dụng SSM để kết nối
  ssh_interface = "session_manager"
  # Instance profile có quyền kết nối tới ssm
  iam_instance_profile = var.iam_instance_profile
}

# Cấu hình build với các bước cài đặt
build {
  sources = ["source.amazon-ebs.backend"]

  provisioner "shell" {
    inline = [
      # debug var
      "echo repo_url: ${var.repo_url}, rds_endpoint_url: ${var.rds_endpoint_url}, commit_hash: ${var.commit_hash}, vpc_id: ${var.vpc_id}, subnet_id: ${var.subnet_id}",
      # Xóa cache của yum để đảm bảo kho lưu trữ sạch
      "sudo yum clean all",
      # Tạo lại cache cho yum với siêu dữ liệu mới
      "sudo yum makecache",
      # Cài đặt các gói phụ thuộc
      "sudo yum install -y git gcc postgresql-devel python3 python3-pip python3-devel",
      # Tạo thư mục ~/app
      "sudo mkdir -p ~/app",
      # Chuyển quyền sở hữu thư mục ~/app cho ec2-user
      "sudo chown ec2-user:ec2-user ~/app",
      # Di chuyển vào thư mục ~/app
      "cd ~/app",
      # Clone repository Git
      "git clone ${var.repo_url} .",
      # Chuyển sang commit hoặc nhánh được chỉ định
      "git checkout ${var.commit_hash}",
      # Di chuyển vào thư mục app/backend/
      "cd app/backend/",
      # Hiển thị nội dung requirements.txt
      "cat requirements.txt",
      # Cài đặt các thư viện Python
      "pip3 install --no-cache-dir -r requirements.txt",
      # Lấy endpoint của RDS instance
      "RDS_ENDPOINT=${var.rds_endpoint_url}",
      # Thay YOUR_RDS_ENDPOINT trong .env
      "sed -i 's/YOUR_RDS_ENDPOINT/'\"$RDS_ENDPOINT\"'/g' .env",
      # Hiển thị nội dung .env
      "cat .env",
      # Kiểm tra sự tồn tại của app.py
      "ls app.py",
      # Tạo thư mục migrations
      "sudo mkdir -p migrations",
      # Chuyển quyền sở hữu thư mục migrations
      "sudo chown ec2-user:ec2-user migrations",
      # Chạy script db_init.py
      "python3 db_init.py",
      # Thiết lập biến môi trường FLASK_APP
      "export FLASK_APP=app.py",
      # Thiết lập môi trường Flask
      "export FLASK_ENV=production",
      # Khởi tạo Flask-Migrate
      "flask db init",
      # Tạo migration mới
      "flask db migrate",
      # Tạo file systemd service cho Gunicorn
      "sudo bash -c 'cat > /etc/systemd/system/flaskapp.service' << 'EOF'",
      "[Unit]",
      "Description=Flask App with Gunicorn",
      "After=network.target",
      "",
      "[Service]",
      "User=ec2-user",
      "WorkingDirectory=/home/ec2-user/app/app/backend",
      "ExecStart=/home/ec2-user/.local/bin/gunicorn -w 4 -b 0.0.0.0:5000 app:app",
      "Restart=always",
      "Environment=FLASK_ENV=production",
      "",
      "[Install]",
      "WantedBy=multi-user.target",
      "EOF",
      # Kích hoạt systemd service
      "sudo systemctl enable flaskapp.service"
    ]
  }
}