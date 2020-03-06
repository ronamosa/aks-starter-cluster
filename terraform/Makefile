.ONESHELL:
.SHELL := /usr/bin/bash
.PHONY: apply destroy plan clean 

VARS="cluster-$(ENV).tfvars"
CURRENT_FOLDER=$(shell basename "$$(pwd)")
WORKSPACE="$(ENV)"

check:
	@if [ -z ${ENV} ]; then \
		echo "ENV was not set"; \
		ERROR=1; \
		exit 1; \
	 fi
	@if [ ! -f "$(VARS)" ]; then \
		echo "$(BOLD)Could not find variables file: $(VARS)"; \
		exit 1; \
	 fi

prep: check 
	@echo "Switching to workspace $(WORKSPACE)"
	@terraform workspace select $(WORKSPACE) || terraform workspace new $(WORKSPACE)
	@terraform init

plan: prep
	@terraform plan \
		-lock=true \
		-input=false \
		-refresh=true \
		-var-file="$(VARS)"

apply: prep 
	@terraform apply \
		-lock=true \
		-input=false \
		-refresh=true \
		-var-file="$(VARS)"

destroy: prep 
	@terraform destroy \
		-lock=true \
		-input=false \
		-refresh=true \
		-var-file="$(VARS)"