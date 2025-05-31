#!/bin/bash

# Script để upload AWS Region và Role ARN lên GitHub Secrets

# Kiểm tra tham số đầu vào
if [ $# -ne 4 ]; then
  echo "Usage: $0 <GITHUB_TOKEN> <REPO> <AWS_REGION> <ROLE_NAME>"
  echo "Example: $0 ghp_xxxxxxxxxxxxxxxx owner/repo us-east-1 my-role"
  exit 1
fi

GITHUB_TOKEN="$1"
REPO="$2"
AWS_REGION="$3"
ROLE_NAME="$4"

# Kiểm tra aws cli có được cài đặt không
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it first."
    exit 1
fi

# Lấy Role ARN từ Role Name sử dụng AWS CLI
ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$ROLE_ARN" ]; then
  echo "Error: Failed to retrieve Role ARN for role $ROLE_NAME"
  exit 1
fi

# Kiểm tra xem các giá trị có rỗng không
if [ -z "$AWS_REGION" ]; then
  echo "Error: AWS_REGION is empty"
  exit 1
fi
if [ -z "$ROLE_ARN" ]; then
  echo "Error: ROLE_ARN is empty"
  exit 1
fi

# Danh sách secrets cần upload
SECRETS=(
  "AWS_REGION"
  "AWS_ROLE_ARN"
)

# Hàm mã hóa secret để sử dụng với GitHub API
encrypt_secret() {
  local secret_value=$1
  local public_key=$2
  # Mã hóa secret theo yêu cầu của GitHub API
  echo -n "$secret_value" | openssl dgst -sha256 -binary | base64
}

# Lấy public key của repository để mã hóa secrets
get_public_key() {
  curl -s -H "Authorization: token $GITHUB_TOKEN" \
       -H "Accept: application/vnd.github.v3+json" \
       "https://api.github.com/repos/$REPO/actions/secrets/public-key"
}

# Tạo hoặc cập nhật secret trên GitHub
create_or_update_secret() {
  local secret_name=$1
  local secret_value=$2
  local key_id=$3
  local public_key=$4

  # Mã hóa secret
  encrypted_value=$(encrypt_secret "$secret_value" "$public_key")

  # Gửi yêu cầu API để tạo/cập nhật secret
  curl -s -X PUT \
       -H "Authorization: token $GITHUB_TOKEN" \
       -H "Accept: application/vnd.github.v3+json" \
       "https://api.github.com/repos/$REPO/actions/secrets/$secret_name" \
       -d "{\"encrypted_value\":\"$encrypted_value\",\"key_id\":\"$key_id\"}"
}

# Lấy public key của repository
public_key_response=$(get_public_key)
if [ -z "$public_key_response" ]; then
  echo "Error: Failed to retrieve public key from GitHub API."
  exit 1
fi

# Trích xuất key_id và public_key từ response
key_id=$(echo "$public_key_response" | jq -r '.key_id')
public_key=$(echo "$public_key_response" | jq -r '.key')

if [ -z "$key_id" ] || [ -z "$public_key" ]; then
  echo "Error: Could not parse key_id or public_key from response."
  exit 1
fi

# Gán giá trị cho AWS_ROLE_ARN
AWS_ROLE_ARN="$ROLE_ARN"

# Upload từng secret lên GitHub
for secret in "${SECRETS[@]}"; do
  echo "Uploading $secret to GitHub Secrets..."
  echo "value ${!secret}"
  create_or_update_secret "$secret" "${!secret}" "$key_id" "$public_key"
  if [ $? -eq 0 ]; then
    echo "Successfully uploaded $secret."
  else
    echo "Error: Failed to upload $secret."
    exit 1
  fi
done

echo "All secrets uploaded successfully!"