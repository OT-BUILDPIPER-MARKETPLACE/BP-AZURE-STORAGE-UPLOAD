#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh

# Optionally enable debugging
if [ "$DEBUG" = true ]; then
  set -x
fi

CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"
logInfoMessage "I'll do processing at [$CODEBASE_LOCATION]"
sleep $SLEEP_DURATION

cd "${CODEBASE_LOCATION}" || exit 1

logInfoMessage "TARGET FILE: $TARGET_FILE"
logInfoMessage "SOURCE DIR: $SOURCE_DIR"
logInfoMessage "STORAGE ACCOUNT: $AZURE_STORAGE_ACCOUNT"
logInfoMessage "CONTAINER NAME: $AZURE_CONTAINER"
logInfoMessage "DESTINATION DIR: $DESTINATION_DIR"

cd "${SOURCE_DIR}"
if [ "$LIST" = true ]; then
  ls -ltr
fi

# ---- Upload using account key ----
az storage blob upload \
  --account-name "$AZURE_STORAGE_ACCOUNT" \
  --account-key "$AZURE_STORAGE_KEY" \
  --container-name "$AZURE_CONTAINER" \
  --name "${DESTINATION_DIR}/${TARGET_FILE}" \
  --file "$TARGET_FILE" \
  --overwrite

TASK_STATUS=$?
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}