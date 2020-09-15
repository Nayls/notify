OK_COLOR=\033[32;01m
NO_COLOR=\033[0m

SHELL=/bin/bash
DOCKER?=$(shell grep alias\ docker= ~/.bashrc | awk -F"'" '{print $$2}')
DOCKER_COMPOSE?=$(shell grep alias\ docker-compose= ~/.bashrc | awk -F"'" '{print $$2}')

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

DOCKER_BUILDKIT=1
CI_REGISTRY_IMAGE?=naylscloud/notify .
CI_COMMIT_REF_SLUG?=$(shell git symbolic-ref --short -q HEAD | sed 's/\//-/')
CI_PIPELINE_URL?=local-build
CI_COMMIT_SHA?=$(shell git rev-parse -q HEAD)
CI_COMMIT_SHORT_SHA?=$(shell git rev-parse --short=8 -q HEAD)

COMMAND?=/bin/bash
DOCKERFILE?=${PWD}/Dockerfile
DOCKER_CONTEXT?=${PWD}
IMAGE_NAME?=${CI_REGISTRY_IMAGE}:${CI_COMMIT_REF_SLUG}

.DEFAULT_GOAL := help

.PHONY: info
info:
	@printf "$(OK_COLOR)==>$(NO_COLOR) Info\n"

	@echo 'DOCKER_BUILDKIT: "${DOCKER_BUILDKIT}"'
	@echo 'CI_REGISTRY_IMAGE: "${CI_REGISTRY_IMAGE}"'
	@echo 'CI_COMMIT_REF_SLUG: "${CI_COMMIT_REF_SLUG}"'
	@echo 'CI_PIPELINE_URL: "${CI_PIPELINE_URL}"'
	@echo 'CI_COMMIT_SHA: "${CI_COMMIT_SHA}"'
	@echo 'CI_COMMIT_SHORT_SHA: "${CI_COMMIT_SHORT_SHA}"'

	@echo 'COMMAND: "${COMMAND}"'
	@echo 'DOCKERFILE: "${DOCKERFILE}"'
	@echo 'DOCKER_CONTEXT: "${DOCKER_CONTEXT}"'
	@echo 'IMAGE_NAME: "${IMAGE_NAME}"'


all: download vendor build run

.PHONY: force-build ## Build with vendor and force rebuild
force-build: download vendor build-force run

.PHONY: run
run: ## Run notify
	@printf "$(OK_COLOR)==>$(NO_COLOR) Run notify\n"
	@./bin/notify

.PHONY: download
download: ## Download packages
	@printf "$(OK_COLOR)==>$(NO_COLOR) Download packages\n"
	@go mod download

.PHONY: vendor
vendor: ## Vendoring packages
	@printf "$(OK_COLOR)==>$(NO_COLOR) Vendoring packages\n"
	@go mod vendor

.PHONY: build
build: ## Build notify
	@printf "$(OK_COLOR)==>$(NO_COLOR) Build notify\n"
	@CGO_ENABLED=0 GOOS=linux go build \
		-mod vendor \
		-ldflags " -X 'main.buildDate="$(date)"' " \
		-installsuffix cgo -o ./bin/notify ./main.go

.PHONY: build-force
build-force: ## Force build notify
	@printf "$(OK_COLOR)==>$(NO_COLOR) Build notify\n"
	@CGO_ENABLED=0 GOOS=linux go build \
		-a \
		-mod vendor \
		-ldflags " -X 'main.buildDate="$(date)"' " \
		-installsuffix cgo -o ./bin/notify ./main.go

.PHONY: docker-build
docker-build: ## Build docker image
	@printf "$(OK_COLOR)==>$(NO_COLOR) Build docker image\n"
	@${DOCKER} build --rm --compress --pull --progress plain \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--tag ${IMAGE_NAME} \
		--target runtime-image \
		--file Dockerfile \
		./
