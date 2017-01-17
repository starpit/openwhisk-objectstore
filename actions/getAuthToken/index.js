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

const ObjectStorage = require('bluemix-objectstorage').ObjectStorage

exports.main = params => {
    return new Promise((resolve, reject) => {
	try {
	    // first, make an os so we can call refreshToken
	    const os1 = new ObjectStorage(params.creds)
	    os1.client.refreshToken()
		.then(() => {
		    try {
			// then make a full os, now that we have the authToken; we need this for os.baseResourceUrl
			delete params.creds.userId
			delete params.creds.password
			const os = new ObjectStorage(params.creds, undefined, os1.client.authToken)
			const fetchObjectUrl = `${os.baseResourceUrl}/${params.container || params.containerName}/{OBJECT_NAME}`

			console.log('includeTemplate?', params.includeTemplate)
			console.log('fetchObjectUrl', fetchObjectUrl)
	    
			resolve(!params.includeTemplate
				? os1.client.authToken
				: {
				    authToken: os1.client.authToken,
				    template: {
					method: 'GET',
					httpMethod: 'GET', // for angular
					url: fetchObjectUrl,
					route: fetchObjectUrl, // for angular
					headers: {
					    'X-Auth-Token': os1.client.authToken.token
					}
				    }
				})
		    } catch (err) {
			console.error(err)
			reject(err)
		    }
		})
		.catch(reject)

	} catch (err) {
	    reject(err)
	}
    })
}
