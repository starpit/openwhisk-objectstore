const wrap = require('./lib/api-wrapper.js')

exports.main = wrap({ api: 'getContainer',
		      project: params => params.containerName,
		      postprocess: (Cp, params) => Cp.then(C => C.createObject(params.objectName,
									       params.isBinary ? Buffer.from(params.data, 'base64') : params.data,
									       params.isBinary))
   		                                     .catch(err => ({ status: 'error', error: err }))
		    })
