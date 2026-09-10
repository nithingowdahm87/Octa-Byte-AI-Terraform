.PHONY: bootstrap-init bootstrap-apply init plan apply destroy fmt validate package-lambdas

bootstrap-init:
	cd bootstrap && terraform init

bootstrap-apply:
	cd bootstrap && terraform apply

init:
	cd environments/$(ENV) && terraform init

validate:
	cd environments/$(ENV) && terraform validate

plan:
	cd environments/$(ENV) && terraform plan -var-file=terraform.tfvars

apply:
	cd environments/$(ENV) && terraform apply -var-file=terraform.tfvars

destroy:
	cd environments/$(ENV) && terraform destroy -var-file=terraform.tfvars

fmt:
	terraform fmt -recursive

package-lambdas:
	bash scripts/package-lambdas.sh
