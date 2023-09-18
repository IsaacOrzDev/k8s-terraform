apply-dev:
	cd dev && terraform apply
update-dev:
	aws ecs update-service --cluster demo-system-cluster --service demo-system-service --force-new-deployment
password:
	aws ecr get-login-password
apply-prod:
	cd prod && terraform apply
apply-prod-password:
	cd prod && terraform apply -var registry_password=$(aws ecr get-login-password)