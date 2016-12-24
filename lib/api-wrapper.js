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
      identity = x => x,
      os = params => new ObjectStorage(params.creds, undefined, params.authToken),
      util = require('util'),
      array = x => util.isArray(x) ? x : [x]

//
// @param args {api:, project:, process:}
// @param params these are the whisk invocation parameters
//
module.exports = args => params => 
    (args.postprocess || identity)(os(params)[args.api].apply(os(params),
							      array(args.project && args.project(params))),
				   params)
