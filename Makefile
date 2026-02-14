# include .env

PACKER_VARS  := packer/packer.pkrvars.hcl
CLUSTER_VARS := terraform/cluster/cluster.auto.tfvars
SERVICE_VARS := terraform/services/services.auto.tfvars \
                terraform/services/consul_kv.auto.tfvars \
                terraform/services/nomad_jobs.auto.tfvars \
                terraform/services/nomad_vars.auto.tfvars \
                terraform/services/volumes.auto.tfvars

help:##..................Show the help
	@e=cho ""
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | sed 's/^/    /'
	@echo ""

	
.PHONY: format
format:##................Format both terraform and nomad job files
	cd terraform/cluster && terraform fmt -recursive -write
	cd terraform/services && terraform fmt -recursive -write
	cd terraform/services/nomad_jobs && nomad fmt -recursive -write
	cd terraform/services/consul_kv && nomad fmt -recursive -write
	cd terraform/services/nomad_vars && nomad fmt -recursive -write

.PHONY: generate-tfvars
generate-tfvars:##.......Generate skeleton tfvars templates from the project
	@bash scripts/generate-tfvars.sh

.PHONY: encrypt-tfvars
encrypt-tfvars:##..........Encrypt tfvars on disk
	@for f in $(PACKER_VARS) $(CLUSTER_VARS) $(SERVICE_VARS); do sops -e -i $$f; done

.PHONY: decrypt-tfvars
decrypt-tfvars:##..........Decrypt tfvars on disk
	@for f in $(PACKER_VARS) $(CLUSTER_VARS) $(SERVICE_VARS); do sops -d -i $$f; done

.PHONY: init-cluster
init-cluster:##..........Initialize terraform for the cluster
	cd terraform/cluster && terraform init

.PHONY: init-upgrade-cluster
init-upgrade-cluster:##. Upgrade terraform with the latest providers
	cd terraform/cluster && terraform init -upgrade

.PHONY: init-services
init-services:##.........Initialize terraform for services
	cd terraform/services && terraform init

.PHONY: init-upgrade-services
init-upgrade-services:## Upgrade terraform with the latest providers
	cd terraform/services && terraform init -upgrade

.PHONY: plan-cluster
plan-cluster:##..........Create a terraform execution plan for the cluster
	cd terraform/cluster && terraform plan

.PHONY: deploy-cluster
deploy-cluster:##.........Execute a terraform plan for the cluster
	cd terraform/cluster && terraform apply --auto-approve

.PHONY: plan-services
plan-services:##.........Create a terraform execution plan for the services
	cd terraform/services && terraform plan

.PHONY: deploy-services
deploy-services:##........Deploy all Nomad job groups sequentially
	cd terraform/services && terraform apply --auto-approve

.PHONY: build-%
build-%:##...............Build an image with packer
	@sops -e -i $(PACKER_VARS)
	@trap 'sops -d -i $(PACKER_VARS)' EXIT; \
		cd packer/$* && packer build -var-file=../packer.pkrvars.hcl .

.PHONY: build-all
build-all:##.............Build all images with packer
	@sops -e -i $(PACKER_VARS)
	@trap 'sops -d -i $(PACKER_VARS)' EXIT; \
		cd packer/base && packer build -var-file=../packer.pkrvars.hcl . && \
		cd ../manager && packer build -var-file=../packer.pkrvars.hcl . && \
		cd ../worker && packer build -var-file=../packer.pkrvars.hcl .
