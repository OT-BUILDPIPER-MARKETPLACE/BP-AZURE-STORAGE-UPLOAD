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

logInfoMessage "SOURCE DIR: $SOURCE_DIR"
logInfoMessage "STORAGE ACCOUNT: $AZURE_STORAGE_ACCOUNT"
logInfoMessage "CONTAINER NAME: $AZURE_CONTAINER"
logInfoMessage "DESTINATION DIR: $DESTINATION_DIR"

cd "${SOURCE_DIR}" || exit 1

UPLOAD_FILES=()

# Case 1: TARGET_FILE provided
if [[ -n "$TARGET_FILE" ]]; then
  UPLOAD_FILES+=("$TARGET_FILE")
else
  # Case 2: No TARGET_FILE → take all .zip files
  shopt -s nullglob
  ZIP_FILES=( *.zip )
  shopt -u nullglob
  UPLOAD_FILES+=("${ZIP_FILES[@]}")
fi

if [[ ${#UPLOAD_FILES[@]} -gt 0 ]]; then
  for file in "${UPLOAD_FILES[@]}"; do
    logInfoMessage "Uploading: $file"
    az storage blob upload \
      --account-name "$AZURE_STORAGE_ACCOUNT" \
      --account-key "$AZURE_STORAGE_KEY" \
      --container-name "$AZURE_CONTAINER" \
      --name "${DESTINATION_DIR}/${file}" \
      --file "$file" \
      --overwrite
    TASK_STATUS=$?
    saveTaskStatus $TASK_STATUS "${ACTIVITY_SUB_TASK_CODE}"
    [[ $TASK_STATUS -ne 0 ]] && exit $TASK_STATUS
  done
else
  logErrorMessage "No TARGET_FILE provided and no .zip files found in $SOURCE_DIR. Upload failed."
  TASK_STATUS=1
  saveTaskStatus $TASK_STATUS "${ACTIVITY_SUB_TASK_CODE}"
fi