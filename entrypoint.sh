#!/bin/sh
set -ex

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
fi

URL1="https://github.com/yoheimuta/protolint/releases/download/v${INPUT_PROTOLINT_VERSION}/protolint_${INPUT_PROTOLINT_VERSION}_Linux_x86_64.tar.gz"
URL2="https://github.com/yoheimuta/protolint/releases/download/v${INPUT_PROTOLINT_VERSION}/protolint_${INPUT_PROTOLINT_VERSION}_linux_amd64.tar.gz"
OUTPUT_FILE="protolint.tar.gz"
# Install protolint
if ! [ -f "protolint" ]; then
  echo "🔄 Installing protolint v${INPUT_PROTOLINT_VERSION}..."
  # Download the file using wget
  if wget -q --spider "$URL1"; then
      wget -O "${OUTPUT_FILE}" "$URL1"
  else
      wget -O "${OUTPUT_FILE}" "$URL2"
  fi
  tar -xf "${OUTPUT_FILE}"
  rm "${OUTPUT_FILE}"
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo "${INPUT_PROTOLINT_FLAGS}" | xargs ./protolint 2>&1 \
  | reviewdog -efm="[%f:%l:%c] %m" \
      -name="linter-name (protolint)" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      "${INPUT_REVIEWDOG_FLAGS}"
