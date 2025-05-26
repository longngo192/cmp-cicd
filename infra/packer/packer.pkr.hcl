# Định nghĩa các biến cho REPO_URL và COMMIT_HASH

variable "repo_url" {
  type    = string
  default = "https://github.com/longngo192/cmp-cicd.git" # Thay bằng URL repository thực tế
}

variable "commit_hash" {
  type    = string
  default = "" # Thay bằng commit hash thực tế
}

variable "rds_endpoint_url" {
  type    = string
  default = "" # Thay bằng rds endpoint đã deploy của các bạn
}

# Cấu hình builder amazon-ebs để tạo AMI
source "amazon-ebs" "backend" {
  ami_name      = "backend-ami-{{timestamp}}" # Tên AMI với timestamp để tránh trùng lặp
  source_ami_filter {
    filters = {
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["679593333241"]
  }
  instance_type = "t3.micro"                  # Loại instance
  region        = "us-east-1"                 # Vùng AWS
  source_ami    = "ami-0f9de6e2d2f067fca"     # AMI Amazone linux 2023 (thay đổi theo vùng nếu cần)
  ssh_username  = "ec2-user"                    # Tên người dùng SSH cho AMI cơ sở
}

# Cấu hình build với các bước cài đặt
build {
  sources = ["source.amazon-ebs.backend"]

  provisioner "shell" {
    inline = [
      # Xóa cache của yum để đảm bảo kho lưu trữ sạch
      "sudo yum clean all",
      # Tạo lại cache cho yum với siêu dữ liệu mới
      "sudo yum makecache",
      # Cài đặt các gói phụ thuộc: git, gcc, postgresql-devel, python3, python3-pip, python3-devel
      "sudo yum install -y git gcc postgresql-devel python3 python3-pip python3-devel",
      # Tạo thư mục ~/app, -p để không báo lỗi nếu thư mục đã tồn tại
      "sudo mkdir -p ~/app",
      # Chuyển quyền sở hữu thư mục ~/app cho ec2-user
      "sudo chown ec2-user:ec2-user ~/app",
      # Di chuyển vào thư mục ~/app
      "cd ~/app",
      # Clone repository Git từ biến githubrepo vào thư mục hiện tại
      "git clone ${var.repo_url} .",
      # Chuyển sang commit hoặc nhánh được chỉ định trong biến hashcommit
      "git checkout ${var.commit_hash}",
      # Di chuyển vào thư mục app/backend/
      "cd app/backend/",
      # Hiển thị nội dung requirements.txt để kiểm tra
      "cat requirements.txt",
      # Cài đặt các thư viện Python từ requirements.txt, --no-cache-dir để tiết kiệm dung lượng
      "pip3 install --no-cache-dir -r requirements.txt",
      # Lấy endpoint của RDS instance webapp-rds-primary và lưu vào biến RDS_ENDPOINT
      "RDS_ENDPOINT=${var.rds_endpoint_url}",
      # Thay YOUR_RDS_ENDPOINT trong .env bằng giá trị RDS_ENDPOINT
      "sed -i 's/YOUR_RDS_ENDPOINT/'\"$RDS_ENDPOINT\"'/g' .env",
      # Hiển thị nội dung .env để kiểm tra
      "cat .env",
      # Kiểm tra sự tồn tại của app.py
      "ls app.py",
      # Tạo thư mục migrations để lưu trữ migration của Flask-Migrate
      "sudo mkdir -p migrations",
      # Chuyển quyền sở hữu thư mục migrations cho ec2-user
      "sudo chown ec2-user:ec2-user migrations",
      # Thiết lập biến môi trường FLASK_APP để chỉ định app.py
      "export FLASK_APP=app.py",
      # Thiết lập môi trường Flask là production
      "export FLASK_ENV=production",
      # Chạy script db_init.py để khởi tạo cơ sở dữ liệu (script tùy chỉnh)
      "python3 db_init.py",
      # Khởi tạo Flask-Migrate, tạo thư mục migrations/
      "flask db init",
      # Tạo migration mới dựa trên models của Flask
      "flask db migrate"

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
      # Kích hoạt systemd service để chạy khi khởi động
      "sudo systemctl enable flaskapp.service"
    ]
  }
}