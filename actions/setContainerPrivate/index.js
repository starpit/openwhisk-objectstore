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

const ObjectStorage = require('bluemix-objectstorage').ObjectStorage,
      os = params => new ObjectStorage(params.creds, undefined, params.authToken),
      request = require('request')

exports.main = params => new Promise((resolve, reject) => {
    try {
	console.log(`${os(params).baseResourceUrl}/${params.containerName || params.container}`)
	request({
	    url: `${os(params).baseResourceUrl}/${params.containerName || params.container}`,
	    method: 'put',
	    headers: {
		'X-Auth-Token': params.authToken.token,
		'X-Remove-Container-Read': 'this string does not matter'
	    }
	}, (err, response, body) => {
	    if (err || response.statusCode >= 400) {
		reject(err || { statusCode: response.statusCode, body: body })
	    } else {
		resolve({ status: 'success', response: body })
	    }
	})
    } catch (e) {
	reject(e)
    }
})
