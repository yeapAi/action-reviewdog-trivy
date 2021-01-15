#!/bin/sh

cd "${GITHUB_WORKSPACE}" || exit

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

echo '::group:: Installing trivy ... https://github.com/hadolint/hadolint'
wget -q https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy${TRIVY_VERSION}_Linux-64bit.tar.gz -O $TEMP_PATH/trivy.tar.gz
tar -xvf $TEMP_PATH/trivy.tar.gz trivy \
    && chmod +x $TEMP_PATH/trivy
echo '::endgroup::'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group:: Running trivy with reviewdog 🐶 ...'
trivy ${INPUT_TRIVY_FLAGS} --format json -o ${GITHUB_ACTION_PATH}/output yeap-dossier-api:latest
cat ${GITHUB_ACTION_PATH}/output | \
jq -f "${GITHUB_ACTION_PATH}/to-rdjson.jq" -c | \
reviewdog -f="rdjson" \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER}" \
    -filter-mode="${INPUT_FILTER_MODE}" \
    -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
    -level="${INPUT_LEVEL}" \
    ${INPUT_REVIEWDOG_FLAGS}
echo '::endgroup::'
