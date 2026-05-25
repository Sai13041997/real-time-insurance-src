SHELL := /usr/bin/env bash

LAMBDA ?=
ENV ?= dev
ARTIFACT_BUCKET ?=
ARTIFACT_KEY ?=

.PHONY: help
help:
	@echo "Targets:"
	@echo "  make package LAMBDA=<lambda_folder>   Package a lambda into .artifacts/<lambda>.zip"
	@echo "  make deploy  LAMBDA=<lambda_folder> ENV=<env> ARTIFACT_BUCKET=<bucket> ARTIFACT_KEY=<key>  Deploy a lambda from S3 artifact"
	@echo "  make changed BASE_REF=<ref>           Print changed lambdas vs BASE_REF"

.PHONY: package
package:
	@if [[ -z "$(LAMBDA)" ]]; then echo "LAMBDA is required"; exit 1; fi
	./scripts/package_lambda.sh "$(LAMBDA)"

.PHONY: deploy
deploy:
	@if [[ -z "$(LAMBDA)" ]]; then echo "LAMBDA is required"; exit 1; fi
	@if [[ -z "$(ARTIFACT_BUCKET)" ]]; then echo "ARTIFACT_BUCKET is required"; exit 1; fi
	@if [[ -z "$(ARTIFACT_KEY)" ]]; then echo "ARTIFACT_KEY is required"; exit 1; fi
	./scripts/deploy_lambda.sh "$(ENV)" "$(LAMBDA)" "$(ARTIFACT_BUCKET)" "$(ARTIFACT_KEY)"

.PHONY: changed
changed:
	@if [[ -z "$(BASE_REF)" ]]; then echo "BASE_REF is required (e.g. origin/main)"; exit 1; fi
	python3 ./scripts/changed_lambdas.py --base-ref "$(BASE_REF)"
