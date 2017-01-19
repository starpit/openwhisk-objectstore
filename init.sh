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

function initOneAction {
    local action="$1"
    
    rm -f "$dir/node_modules" "$dir/lib"
    (cd "$dir" && ln -s ../../node_modules node_modules && ln -s ../../lib lib)

    (cd $dir \
	    && zip --exclude *~ -q -r action.zip * \
	    && wsk action update --kind nodejs:6 "${PACKAGE}/${action}" action.zip; \
     rm -f action.zip)

    # see if the action needs the full credentials (i.e. including login credentials)
    if [ -f "$dir/config.json" ]; then
	C=`cat "$dir/config.json" | jq --raw-output .credentials`
	if [ "$C" == "full" ]; then
	    echo "Using full credentials for ${action}"
	    wsk action update "${PACKAGE}/${action}" -p creds "${CREDS}"

	    # add a with-authentication variant to any actions that require full credentials
	    wsk action list | grep oauth/validate
	    if [ $? == 0 ]; then
		wsk action update --sequence "${PACKAGE}/${action}-with-authz-check" oauth/validate,"${PACKAGE}/${action}"
	    fi

	fi
    fi
    
    rm -f "$dir/node_modules" "$dir/lib"
}

for dir in actions/*/; do
    action=$(basename "$dir")
    initOneAction "$action" &
done

# wait for the subprocesses to finish
wait

if [ -n "${ENDPOINTS}" ]; then
    wsk api-experimental create /${PACKAGE} /getObjectAsReq post ${PACKAGE}/getObjectAsReq 2>&1 | grep -v "already exists"
    GETOBJECTASREQ_ENDPOINT=`wsk api-experimental list /${PACKAGE} | grep getObjectAsReq | awk '{print $NF}'`

    echo "getObjectAsReq=${GETOBJECTASREQ_ENDPOINT}" >> ${ENDPOINTS}
fi
