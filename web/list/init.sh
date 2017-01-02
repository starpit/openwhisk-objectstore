#!/usr/bin/env bash

CONTAINER=inbox

# take the page name from the name of the current directory
PAGE=${PWD##*/}

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
wsk action list | grep objectstore/getAuthToken-with-authentication >& /dev/null
if [ $? == 0 ]; then
    GAT=objectstore/getAuthToken-with-authentication
else
    GAT=objectstore/getAuthToken
fi
GET_TOKEN_ENDPOINT=`wsk api-experimental create /objectstore /getAuthToken get "$GAT" | grep https`

wsk api-experimental delete /objectstore /listObjectsInInbox | grep -v "does not exist in the DB doc"
LIST_ENDPOINT=`wsk api-experimental create /objectstore /listObjectsInInbox post objectstore-${CONTAINER}/listObjects | grep https`

# FIXME, how do we avoid hard-coding these?
LOGIN_ENDPOINT="https://dal.objectstorage.open.softlayer.com/v1/AUTH_8505e32a0c1a48c2b7a37c063adad2ba/public/login.html"
UPLOAD_ENDPOINT="https://dal.objectstorage.open.softlayer.com/v1/AUTH_8505e32a0c1a48c2b7a37c063adad2ba/public/upload.html"

STYLE_COMMON="`cat ../common/common.css | tr -d '\n'`"

awk -v UPLOAD_ENDPOINT="${UPLOAD_ENDPOINT}" -v CONTAINER="${CONTAINER}" -v PAGE="${PAGE}" -v STYLE_COMMON="${STYLE_COMMON}" -v GET_TOKEN_ENDPOINT="${GET_TOKEN_ENDPOINT}" -v LIST_ENDPOINT="${LIST_ENDPOINT}" -v LOGIN_ENDPOINT="${LOGIN_ENDPOINT}" '{gsub("{CONTAINER}", CONTAINER); gsub("{UPLOAD_ENDPOINT}", UPLOAD_ENDPOINT); gsub("{PAGE}", PAGE); gsub("{STYLE_COMMON}", STYLE_COMMON); gsub("{GET_TOKEN_ENDPOINT}", GET_TOKEN_ENDPOINT); gsub("{LIST_ENDPOINT}", LIST_ENDPOINT); gsub("{LOGIN_ENDPOINT}", LOGIN_ENDPOINT); print $0}' ${PAGE}-template.html > ${PAGE}.html

../common/publish.sh ${PAGE}.html

