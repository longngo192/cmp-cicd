#!/bin/bash

# Đường dẫn đến tệp cấu hình AWS
AWS_CREDENTIALS_FILE="$HOME/.aws/credentials"

# Kiểm tra xem tệp có tồn tại không
if [ ! -f "$AWS_CREDENTIALS_FILE" ]; then
  echo "Tệp $AWS_CREDENTIALS_FILE không tồn tại."
  exit 1
fi

# Đọc AWS_ACCESS_KEY_ID từ tệp
AWS_ACCESS_KEY_ID=$(awk -F' = ' '/aws_access_key_id/ {print $2}' "$AWS_CREDENTIALS_FILE" | head -n 1)

# Đọc AWS_SECRET_ACCESS_KEY từ tệp
AWS_SECRET_ACCESS_KEY=$(awk -F' = ' '/aws_secret_access_key/ {print $2}' "$AWS_CREDENTIALS_FILE" | head -n 1)

# Kiểm tra xem các giá trị có được đọc thành công không
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Không thể tìm thấy AWS_ACCESS_KEY_ID hoặc AWS_SECRET_ACCESS_KEY trong $AWS_CREDENTIALS_FILE."
  exit 1
fi

# Export các biến môi trường
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY


echo "Đã export AWS_ACCESS_KEY_ID và AWS_SECRET_ACCESS_KEY vào biến môi trường."
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY