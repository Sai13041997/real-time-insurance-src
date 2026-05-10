#!/usr/bin/env bash
set -euo pipefail

LAMBDA="${1:?lambda folder name required}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAMBDA_DIR="${ROOT}/lambdas/${LAMBDA}"
SRC_DIR="${LAMBDA_DIR}/src"
REQ_FILE="${LAMBDA_DIR}/requirements.txt"

if [[ ! -d "${LAMBDA_DIR}" ]]; then
  echo "Lambda folder not found: ${LAMBDA_DIR}" >&2
  exit 1
fi

if [[ ! -d "${SRC_DIR}" ]]; then
  echo "Missing src dir: ${SRC_DIR}" >&2
  exit 1
fi

ARTIFACT_DIR="${ROOT}/.artifacts"
BUILD_DIR="${ROOT}/.packages/${LAMBDA}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}" "${ARTIFACT_DIR}"

# Install deps (if requirements.txt exists and non-empty)
if [[ -f "${REQ_FILE}" ]] && [[ -s "${REQ_FILE}" ]]; then
  python3 -m pip install --upgrade pip >/dev/null
  python3 -m pip install -r "${REQ_FILE}" -t "${BUILD_DIR}/python" >/dev/null
fi

# Copy source code
cp -R "${SRC_DIR}/." "${BUILD_DIR}/"

# Zip it
pushd "${BUILD_DIR}" >/dev/null
ZIP_PATH="${ARTIFACT_DIR}/${LAMBDA}.zip"
rm -f "${ZIP_PATH}"

# Make ZIP_PATH available to the python process
export ZIP_PATH

python3 - <<'PY'
import os, zipfile

zip_path = os.environ["ZIP_PATH"]
with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as z:
    for root, dirs, files in os.walk("."):
        for f in files:
            full = os.path.join(root, f)
            z.write(full, full)
print(zip_path)
PY

popd >/dev/null

echo "Packaged: ${ZIP_PATH}"
