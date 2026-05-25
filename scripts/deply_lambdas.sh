#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${1:?env required (e.g. dev/prod)}"
LAMBDA="${2:?lambda folder name required}"
ARTIFACT_BUCKET="${3:?artifact bucket required}"
ARTIFACT_KEY="${4:?artifact key required}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_LAMBDAS="${ROOT}/config/lambdas.yml"
CONFIG_ENVS="${ROOT}/config/environments.yml"

read -r FUNCTION_NAME AWS_REGION < <(
  python3 -c '
import yaml
from pathlib import Path

LAMBDA = "'"${LAMBDA}"'"
ENV = "'"${ENV_NAME}"'"

lambdas = yaml.safe_load(Path("'"${CONFIG_LAMBDAS}"'").read_text())
envs = yaml.safe_load(Path("'"${CONFIG_ENVS}"'").read_text())

if LAMBDA not in lambdas["lambdas"]:
    raise SystemExit(f"Lambda {LAMBDA!r} not found in config/lambdas.yml")

fn = lambdas["lambdas"][LAMBDA]["function_name"].get(ENV)
if not fn:
    raise SystemExit(f"Missing function_name for env {ENV!r} for lambda {LAMBDA!r}")

region = envs["environments"][ENV]["aws_region"]
print(fn, region)
'
)

echo "Deploying ${LAMBDA} -> ${FUNCTION_NAME} (env=${ENV_NAME}, region=${AWS_REGION})"

echo "Using durable artifact: s3://${ARTIFACT_BUCKET}/${ARTIFACT_KEY}"
aws lambda update-function-code \
  --region "${AWS_REGION}" \
  --function-name "${FUNCTION_NAME}" \
  --s3-bucket "${ARTIFACT_BUCKET}" \
  --s3-key "${ARTIFACT_KEY}"

echo "Deployed."
