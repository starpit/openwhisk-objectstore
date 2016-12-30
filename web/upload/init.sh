#!/usr/bin/env bash

CONTAINER=inbox

export OS_AUTH=`../../util/getAuthToken.sh`

wsk action invoke objectstore/listContainers -b -r -p authToken "${OS_AUTH}" | grep ${CONTAINER} > /dev/null
if [ $? == 1 ]; then
    (wsk action invoke objectstore/createContainer -b -r \
	-p authToken "${OS_AUTH}" \
	-p container ${CONTAINER}) > /dev/null
    if [ $? == 1 ]; then exit; else echo "Created container ${CONTAINER}"; fi
fi

(wsk action invoke objectstore/setContainerMetadata -b -r \
     -p authToken "${OS_AUTH}" \
     -p container ${CONTAINER} \
     -p metadata  "{\"Access-Control-Allow-Origin\": \"*\", \"Access-Control-Expose-Headers\": \"content-type\"}") > /dev/null
if [ $? == 1 ]; then exit; else echo "Added CORS to container ${CONTAINER}"; fi


wsk package bind objectstore objectstore-${CONTAINER} -p container ${CONTAINER} 2>&1 | grep -v "resource already exists"

wsk api-experimental delete /objectstore /getAuthToken
GET_TOKEN_ENDPOINT=`wsk api-experimental create /objectstore /getAuthToken get objectstore/getAuthToken | grep https`

wsk api-experimental delete /objectstore /createObjectAsReq
UPLOAD_ENDPOINT=`wsk api-experimental create /objectstore /createObjectAsReq post objectstore-${CONTAINER}/createObjectAsReq | grep https`


awk -v GET_TOKEN_ENDPOINT="${GET_TOKEN_ENDPOINT}" -v UPLOAD_ENDPOINT="${UPLOAD_ENDPOINT}" '{gsub("{GET_TOKEN_ENDPOINT}", GET_TOKEN_ENDPOINT); gsub("{UPLOAD_ENDPOINT}", UPLOAD_ENDPOINT); print $0}' upload-template.html > upload.html

../common.sh upload.html

