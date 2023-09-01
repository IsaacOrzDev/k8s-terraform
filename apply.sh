cd dev
terraform apply -var registry_password=$(aws ecr get-login-password)