const wrap = require('./lib/api-wrapper.js')

exports.main = wrap({ api: 'createContainer',
		      project: params => params.containerName,
		      postprocess: Cp => Cp.then(C => ({ status: 'success', containerName: C.name }))
   		                           .catch(err => ({ status: 'error', error: err }))
		    })
