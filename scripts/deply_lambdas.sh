#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${1:?env required (e.g. dev/prod)}"
LAMBDA="${2:?lambda folder name required}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_LAMBDAS="${ROOT}/config/lambdas.yml"
CONFIG_ENVS="${ROOT}/config/environments.yml"

ZIP_PATH="${ROOT}/.artifacts/${LAMBDA}.zip"
if [[ ! -f "${ZIP_PATH}" ]]; then
  echo "Artifact not found. Run package first: ${ZIP_PATH}" >&2
  exit 1
fi

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

aws lambda update-function-code \
  --region "${AWS_REGION}" \
  --function-name "${FUNCTION_NAME}" \
  --zip-file "fileb://${ZIP_PATH}"

echo "Deployed."
