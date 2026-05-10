#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${1:?env required (e.g. dev/prod)}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_ENVS="${ROOT}/config/environments.yml"

read -r ENABLED REGION REST_API_ID STAGE_NAME < <(
  python3 -c '
import yaml
from pathlib import Path

ENV = "'"${ENV_NAME}"'"
envs = yaml.safe_load(Path("'"${CONFIG_ENVS}"'").read_text())
cfg = envs["environments"][ENV]

apigw = cfg.get("apigw", {}) or {}
enabled = bool(apigw.get("enabled", False))
region = cfg["aws_region"]
rest_api_id = apigw.get("rest_api_id", "") or ""
stage_name = apigw.get("stage_name", "") or ""

print(str(enabled).lower(), region, rest_api_id, stage_name)
'
)

if [[ "${ENABLED}" != "true" ]]; then
  echo "API Gateway redeploy disabled for env=${ENV_NAME}; skipping."
  exit 0
fi

if [[ -z "${REST_API_ID}" || -z "${STAGE_NAME}" || "${REST_API_ID}" == "REPLACE_ME" ]]; then
  echo "API Gateway config not set (rest_api_id/stage_name) in config/environments.yml; skipping."
  exit 0
fi

echo "Creating REST API deployment for rest_api_id=${REST_API_ID} stage=${STAGE_NAME} region=${REGION}"

aws apigateway create-deployment \
  --region "${REGION}" \
  --rest-api-id "${REST_API_ID}" \
  --stage-name "${STAGE_NAME}" \
  --description "Deployment from real-time-insurance-src (${ENV_NAME}) $(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "API Gateway deployment created."
