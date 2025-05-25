# Định nghĩa các biến cho REPO_URL và COMMIT_HASH

variable "repo_url" {
  type    = string
  default = "https://github.com/longngo192/cmp-cicd.git" # Thay bằng URL repository thực tế
}

variable "commit_hash" {
  type    = string
  default = "a74ecddb20c036840cca2f5cbdfba660ace326f0" # Thay bằng commit hash thực tế
}

variable "database_url" {
  type      = string
  default   = "" # Optional: leave empty to require it at build time
  sensitive = true
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
      # Debug user and permissions
      "whoami",
      "ls -ld /",
      # Clear any held packages and reset package manager
      "sudo yum clean all || { echo 'yum clean failed'; exit 1; }",
      "sudo yum makecache || { echo 'yum makecache failed'; exit 1; }",
      # Install dependencies
      "sudo yum install -y git gcc postgresql-devel python3 python3-pip python3-devel || { echo 'yum install failed'; exit 1; }",
      # Create /app directory and set ownership
      "sudo mkdir -p /app || { echo 'mkdir /app failed'; exit 1; }",
      "sudo chown ec2-user:ec2-user /app",
      "cd /app",
      "git clone ${var.repo_url} . || { echo 'Git clone failed'; exit 1; }",
      "git checkout ${var.commit_hash} || { echo 'Git checkout failed'; exit 1; }",
      # Verify and install Python dependencies
      "ls /app/requirements.txt || { echo 'requirements.txt not found'; exit 1; }",
      "cat /app/requirements.txt",
      "sudo pip3 install --no-cache-dir -r /app/requirements.txt || { echo 'pip3 install failed'; exit 1; }",
      "export PATH=$PATH:/usr/local/bin",
      "pip3 show Flask || { echo 'Flask not installed'; exit 1; }",
      "pip3 show python-dotenv || { echo 'python-dotenv not installed'; exit 1; }",
      "which flask || { echo 'flask command not found'; exit 1; }",
      # Create .env file with DATABASE_URL from variable
      "[ -n \"${var.database_url}\" ] || { echo 'DATABASE_URL not provided'; exit 1; }",
      "echo 'DATABASE_URL=${var.database_url}' > /app/.env",
      "cat /app/.env",
      # Verify app.py
      "ls /app/app.py || { echo 'app.py not found'; exit 1; }",
      "sudo mkdir -p /app/migrations || { echo 'mkdir /app/migrations failed'; exit 1; }",
      "sudo chown ec2-user:ec2-user /app/migrations",
      "export FLASK_APP=/app/app.py",
      "export FLASK_ENV=production",
      "flask db init || { echo 'flask db init failed'; exit 1; }",
      "flask db migrate || { echo 'flask db migrate failed'; exit 1; }"
    ]
  }
}