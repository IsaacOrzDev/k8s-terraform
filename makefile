apply-shared:
	cd shared && terraform apply
apply-dev:
	cd dev && terraform apply
update-dev:
	aws ecs update-service --cluster sketch-blend-cluster --service sketch-blend-service --force-new-deployment
password:
	aws ecr get-login-password
apply-prod:
	cd prod && terraform apply
apply-local:
	cd local && terraform apply
apply-local-password:
	cd local && terraform apply -var registry_password=$(aws ecr get-login-password)
minikube-start:
	minikube start
minikube-tunnel:
	minikube tunnel