
export PYTHONPATH = ./

export TF_VAR_OPEN_BROWSER_URL 	   = ${OPEN_BROWSER_URL}
export TF_VAR_COUNT_REPLICAS 	   = ${COUNT_REPLICAS}

export DOCKER_IMAGE = ghcr.io/cesarbruschetta/docker-open-url
export DOCKER_TAG ?= latest

# SET .env and override default envs
ifneq (,$(wildcard ./.env))
    include .env
	export $(shell sed 's/=.*//' .env)
endif


.PHONY       : help
.DEFAULT_GOAL: help

help:  ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort


docker_build: ## Build docker image
	@docker build \
	--platform linux/amd64 \
	-t ${DOCKER_IMAGE}:${DOCKER_TAG} \
	./docker
	
deploy_terraform: ## Deploy terraform
	@terraform \
	-chdir=./terraform \
	apply -auto-approve

terraform_destroy: ## Destroy terraform
	@terraform \
	-chdir=./terraform \
	destroy
