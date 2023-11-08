apply-shared:
	cd shared && terraform apply
apply-dev:
	cd dev && terraform apply
update-dev:
	aws ecs update-service --cluster sketch-blend-cluster --service sketch-blend-service --force-new-deployment
password:
	aws ecr get-login-password
apply-prod-eks:
	cd prod && terraform apply --target module.eks
apply-prod-k8s:
	cd prod && terraform apply --target module.k8s-config
config-prod:
	aws eks update-kubeconfig --name sketch_blend --region us-west-1
destroy-prod-eks:
	cd prod && terraform destroy --target module.eks
destroy-prod-k8s:
	cd prod && terraform destroy --target module.k8s-config
apply-local:
	cd local && terraform apply
destroy-local:
	cd local && terraform destroy --target module.k8s-config
apply-local-password:
	cd local && terraform apply -var registry_password=$(aws ecr get-login-password)
minikube-start:
	minikube start
minikube-ingress:
	minikube addons enable ingress
minikube-tunnel:
	minikube tunnel