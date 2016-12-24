const wrap = require('./lib/api-wrapper.js')

exports.main = wrap({ api: 'getContainer',
		      project: params => params.containerName,
		      postprocess: (Cp, params) => Cp.then(C => ({ method: 'PUT',
								   url: `${C.baseResourceUrl}/${params.objectName}`,
								   body: 'replace this with your object',
								   headers: { 'X-Detect-Content-Type': params.isBinary,
									      'X-Auth-Token': 'replace this with your auth token' }
								 })
							  )
   		                                     .catch(err => ({ status: 'error', error: err }))
		    })
