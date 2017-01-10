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
if [ "$1" == "--no-oauth" ]; then
    GAT=objectstore/getAuthToken
    GAT_METHOD=get
else    
    wsk action list | grep objectstore/getAuthToken-with-authz-check >& /dev/null
    if [ $? == 0 ]; then
	echo "getAuthToken will be protected with authorization check"
	GAT=objectstore/getAuthToken-with-authz-check
	GAT_METHOD=post
    else
	GAT=objectstore/getAuthToken
	GAT_METHOD=get
    fi
fi
GET_TOKEN_ENDPOINT=`wsk api-experimental create /objectstore /getAuthToken "$GAT_METHOD" "$GAT" | grep https`
echo "getAuthToken endpoint: ${GET_TOKEN_ENDPOINT}"

wsk api-experimental delete /objectstore /createObjectAsReq
UPLOAD_ENDPOINT=`wsk api-experimental create /objectstore /createObjectAsReq post objectstore-${CONTAINER}/createObjectAsReq | grep https`

# FIXME, how do we avoid hard-coding this?
LOGIN_ENDPOINT="https://dal.objectstorage.open.softlayer.com/v1/AUTH_8505e32a0c1a48c2b7a37c063adad2ba/public/login.html"
ANALYZE_ENDPOINT="https://8c979b4f-8213-4556-b4e1-db03f4a3b326-gws.api-gw.mybluemix.net/cogdigity/analyze"

awk -v ANALYZE_ENDPOINT="${ANALYZE_ENDPOINT}" -v GET_TOKEN_ENDPOINT="${GET_TOKEN_ENDPOINT}" -v UPLOAD_ENDPOINT="${UPLOAD_ENDPOINT}" -v LOGIN_ENDPOINT="${LOGIN_ENDPOINT}" '{gsub("{ANALYZE_ENDPOINT}", ANALYZE_ENDPOINT); gsub("{GET_TOKEN_ENDPOINT}", GET_TOKEN_ENDPOINT); gsub("{UPLOAD_ENDPOINT}", UPLOAD_ENDPOINT); gsub("{LOGIN_ENDPOINT}", LOGIN_ENDPOINT); print $0}' upload-template.html > upload.html

../common/publish.sh upload.html

