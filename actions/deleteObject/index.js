const wrap = require('./lib/api-wrapper.js')

exports.main = wrap({ api: 'getContainer',
		      project: params => params.containerName,
		      postprocess: (Cp, params) => Cp.then(C => C.deleteObject(params.objectName)
							   .then(() => ({ status: 'success' }))
   							   .catch(err => ({ status: 'error', error: err })))
   		                                     .catch(err => ({ status: 'error', error: err }))
		    })
