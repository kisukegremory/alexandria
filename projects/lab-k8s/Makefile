helm-install:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install meu-lab-lgtm prometheus-community/kube-prometheus-stack --namespace observabilidade --create-namespace
set-cloud:
	export DIGITALOCEAN_TOKEN="##############"
set-k8s:
	export KUBECONFIG="/home/gustavo/coding/alexandria/projects/lab-k8s/kubeconfig-do.yaml"
