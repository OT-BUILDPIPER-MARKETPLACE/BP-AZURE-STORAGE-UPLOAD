# bp_azure_storage_uploader_step
I'll let people to upload file in azure storage via this step

## Setup
* Clone the code available at [BP-AZURE-STORAGE-UPLOAD](https://github.com/OT-BUILDPIPER-MARKETPLACE/BP-AZURE-STORAGE-UPLOAD)
* Build the docker image

```
git submodule init
git submodule update
docker build -t ot/azure-storage-uploader-step:0.1 .
```

* Do local testing via image only

```
# upload with default 
docker run -it --rm \
  -v $PWD:/src \
  -e WORKSPACE=/src \
  -e CODEBASE_DIR=/ \
  -e AZURE_STORAGE_ACCOUNT=<storage_account_name> \
  -e AZURE_STORAGE_KEY=<storage_account_key> \
  -e AZURE_STORAGE_CONTAINER=<container_name> \
  ot/azure-storage-uploader-step:0.1

# upload with specific bucket name and file to be uploaded
docker run -it --rm \
  -v $PWD:/src \
  -e TARGET_FILE=build.sh \
  -e SOURCE_DIR=/app \
  -e DESTINATION_DIR=app \
  -e AZURE_STORAGE_ACCOUNT=<storage_account_name> \
  -e AZURE_STORAGE_KEY=<storage_account_key> \
  -e AZURE_STORAGE_CONTAINER=test-container \
  -e WORKSPACE=/src \
  -e CODEBASE_DIR=/ \
  ot/azure-storage-uploader-step:0.0.1
```
