#!/usr/bin/env bash

PACKAGE=objectstore
OBJECTSTORE=documents
OBJECTSTORE_SERVICE_KEY=testclient

CREDS="`cf service-key $OBJECTSTORE $OBJECTSTORE_SERVICE_KEY | grep -v Getting`"
#VCAP_SERVICES="{\"Object-Storage\": [{\"credentials\": $CREDS}]}"
if [ $? != 0 ]; then
    echo "Error fetching ObjectStore service key"
    exit $?
fi

npm install >& /dev/null

wsk package create "${PACKAGE}" 2>&1 | grep -v "resource already exists"
wsk package update "${PACKAGE}" -p creds "${CREDS}"

for dir in actions/*/; do
    action=$(basename "$dir")
    rm -f "$dir/node_modules"
    (cd "$dir" && ln -s ../../node_modules node_modules)

    wsk action delete "${PACKAGE}/${action}" 2>&1 | grep -v "resource does not exist"
    (cd $dir \
	    && echo "${PACKAGE}/${action}" \
	    && zip --exclude *~ -q -r action.zip * \
	    && wsk action create --kind nodejs:6 "${PACKAGE}/${action}" action.zip; \
     rm -f action.zip)
    
    rm -f "$dir/node_modules"
done
