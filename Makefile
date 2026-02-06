# include .env

help:##..................Show the help
	@e=cho ""
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | sed 's/^/    /'
	@echo ""

.PHONY: init-cluster
init-cluster:##..........Initialize terraform for the cluster
	cd terraform/cluster && terraform init

.PHONY: init-services
init-services:##.........Initialize terraform for services
	cd terraform/services && terraform init

.PHONY: init-upgrade-cluster
init-upgrade-cluster:##. Upgrade terraform with the latest providers
	cd terraform/cluster && terraform init -upgrade

.PHONY: init-upgrade-services
init-upgrade-services:## Upgrade terraform with the latest providers
	cd terraform/services && terraform init -upgrade

.PHONY: plan-cluster
plan-cluster:##..........Create a terraform execution plan for the cluster
	cd terraform/cluster && terraform plan

.PHONY: plan-services
plan-services:##.........Create a terraform execution plan for the services
	cd terraform/services && terraform plan

.PHONY: deploy-cluster
deploy-cluster:##.........Execute a terraform plan for the cluster
	cd terraform/cluster && terraform apply --auto-approve

.PHONY: deploy-services
deploy-services:##........Execute a terraform plan for the services
	cd terraform/services && terraform apply --auto-approve 

.PHONY: format
format:##................Format both terraform and nomad job files
	cd terraform/cluster && terraform fmt -recursive -write
	cd terraform/services && terraform fmt -recursive -write
	cd terraform/services/nomad_jobs && nomad fmt -recursive -write

.PHONY: validate-jobs
validate-jobs:##.........Validate all nomad jobs for correctness
	./terraform/scripts/validate-jobs.sh

# .PHONY: build-%
# build-%:##...............Build an image with packer
# 	cd packer/$* && packer build -var-file=../packer.pkrvars.hcl .

.PHONY: build-%
build-%:##...............Build an image with packer
	cd packer/$* && packer build -var-file=../packer.pkrvars.hcl .

.PHONY: build-all

build-all:##.............Build all images with packer
	cd packer/base && packer build -var-file=../packer.pkrvars.hcl .
	cd packer/manager && packer build -var-file=../packer.pkrvars.hcl .
	cd packer/worker && packer build -var-file=../packer.pkrvars.hcl .
