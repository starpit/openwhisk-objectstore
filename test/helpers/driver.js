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

const test = require('ava').test,
      path = require('path'),
      expandHomeDir = require('expand-home-dir'),
      propertiesParser = require('properties-parser'),
      wskprops = propertiesParser.read(process.env.WSK_CONFIG_FILE || expandHomeDir('~/.wskprops')),
      owProps = {
	  apihost: wskprops.APIHOST || 'openwhisk.ng.bluemix.net',
          api_key: wskprops.AUTH,
          namespace: wskprops.NAMESPACE || '_',
          ignore_certs: process.env.NODE_TLS_REJECT_UNAUTHORIZED == "0"
      },
      ow = require('openwhisk')(owProps),
      config = propertiesParser.read(path.join('config', 'config.js'))

function Driver() {
}

const doTest = (expectFailure, description, doThis) =>
      test(description, t => new Promise((resolve, reject) =>
	  ow.actions.invoke({ actionName: `${config.PACKAGE}/getAuthToken`, blocking: true })
	      .then(authTokenActivation => {
		  doThis(authTokenActivation.response.result, config, ow)
		      .then(result => (expectFailure ? reject : resolve)(result))
		      .catch(err => (expectFailure ? resolve : reject)(err));
	      }).catch(err => reject(err))
      ))

Driver.prototype.it = {
    should: doTest.bind(this, false),
    shouldFail: doTest.bind(this, true)
};


module.exports = new Driver().it
