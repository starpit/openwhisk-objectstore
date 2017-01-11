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

const wrap = require('./lib/api-wrapper.js')

exports.main = wrap({ api: 'getContainer',
		      project: params => params.containerName || params.container,
		      postprocess: (Cp, params) => Cp.then(C => C.getObject(params.objectName)
							   .then(obj => ({
							       method: 'GET',
							       httpMethod: 'GET', // for angular
							       url: `${C.baseResourceUrl}/${params.objectName}`,
							       route: `${C.baseResourceUrl}/${params.objectName}`, // for angular
							       headers: {
								   'X-Auth-Token': params.authToken
								       ? params.authToken.token
								       : 'replace this with your auth token'
							       }
							   }))
   							   .catch(err => ({ status: 'error', error: err })))
   		                                     .catch(err => ({ status: 'error', error: err }))
		    })
