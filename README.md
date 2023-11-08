# Sketch Blend Terraform

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

This repo contains the Terraform code for the Sketch Blend project. It is used to create the EKS / ECS of AWS infrastructure and Kubernetes config for the project.

## Getting Started

Local environment:

- Running application and services in Kubernetes with minikube in local
- Setup:
  - Run command: `make minikube-start` to start minikube
  - Run command: `make apply-local-password` to setup services and ingress
  - Run command: `make minikube-tunnel` to setup tunnel for ingress
  - Access the api with the domain: `http://localhost/docs`

Dev environment:

- Running application and services in AWS ECS
- Setup:
  - Run command: `make apply-dev` to setup ecs and services
  - Access the api with the domain: `https://sketch-blend-api-dev.isaacdev.net/docs`

Prod environment:

- Running application and services in Kubernetes with AWS EKS
- Setup:
  - Run command: `make apply-prod-eks` to setup eks and kube_system pods
  - Run command: `make config-prod` to add cluster config to kubectl
  - Run command: `make apply-prod-k8s` to setup services and ingress
  - Access the api with the domain: `https://sketch-blend-api.isaacdev.net/docs`
