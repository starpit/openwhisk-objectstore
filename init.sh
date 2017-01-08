#!/usr/bin/env bash

. ./config/config.js

OBJECTSTORE=${1-documents}
OBJECTSTORE_SERVICE_KEY=${2-testclient}

CREDS="`cf service-key $OBJECTSTORE $OBJECTSTORE_SERVICE_KEY | grep -v Getting`"
#VCAP_SERVICES="{\"Object-Storage\": [{\"credentials\": $CREDS}]}"
if [ $? != 0 ]; then
    echo "Error fetching ObjectStore service key"
    exit $?
fi

# remove login credentials
CREDS_WITHOUT_PASSWORD=`echo $CREDS | jq 'del(.userId)' | jq 'del(.password)' | jq 'del(.username)'`

npm install --production >& /dev/null
npm prune --production >& /dev/null

wsk package create "${PACKAGE}" 2>&1 | grep -v "resource already exists"
wsk package update "${PACKAGE}" -p creds "${CREDS_WITHOUT_PASSWORD}"

for dir in actions/*/; do
    action=$(basename "$dir")
    
    rm -f "$dir/node_modules"
    (cd "$dir" && ln -s ../../node_modules node_modules && ln -s ../../lib lib)

    (cd $dir \
	    && echo "${PACKAGE}/${action}" \
	    && zip --exclude *~ -q -r action.zip * \
	    && wsk action update --kind nodejs:6 "${PACKAGE}/${action}" action.zip; \
     rm -f action.zip)

    # see if the action needs the full credentials (i.e. including login credentials)
    if [ -f "$dir/config.json" ]; then
	C=`cat "$dir/config.json" | jq --raw-output .credentials`
	if [ "$C" == "full" ]; then
	    echo "Using full credentials for ${action}"
	    wsk action update "${PACKAGE}/${action}" -p creds "${CREDS}"
	fi
    fi
    
    rm -f "$dir/node_modules" "$dir/lib"
done
