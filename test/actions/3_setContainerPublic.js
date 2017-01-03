/*
 * Copyright 2015-2016 IBM Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import it from '../helpers/driver'
import util from 'util'
import request from 'request'

it.should('set a container public, and fetch object without authentication', (authToken, config, ow) => new Promise((resolve, reject) => {
    const containerName = 'container-test'
    const objectName = 'object-test.txt'
    
    ow.actions.invoke({
	actionName: `${config.PACKAGE}/setContainerPublic`,
	blocking: true,
	params: {
	    authToken: authToken,
	    containerName: containerName,
	    objectName: objectName
	}
    }).then(activation => {
	!activation.response.result.error
	// now try to fetch it directly with an unathenticated http request
	    ? request({
		url: activation.response.result.templateURL.replace("${objectName}", objectName),
		method: "GET"
	    }, function(err, response, body) {
		if (err || response.statusCode != 200) {
		    reject(`Error fetching object: ${err || response.statusCode}`)
		} else {
		    resolve() // SUCCESS
		}
	    })
	: reject(activation.response.result)
    }).catch(reject)
}))
