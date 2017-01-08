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

// todo this is shared with getContainerID
const containerID = c => c.baseResourceUrl.match(/\/.*AUTH_([^\/]+).*/)[1]

//
// we have to post-process things, with the Lp=> bit,
// because whisk requires a JSONObject, i.e. JSONArray doesn't count
// plus, we want just the name field
//
const full = c => {
    delete c.objectStorage
    delete c.client
    c.containerID = containerID(c)
    return c
}
const partial = c => c.name

exports.main = wrap({ api: 'listContainers',
		      postprocess: (Lp, params) => Lp.then(L => ({ containers: params.include_docs
								   ? L.map(full)
								   : L.map(partial) }) )
		    })
