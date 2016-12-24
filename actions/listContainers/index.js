const wrap = require('./lib/api-wrapper.js')

//
// we have to post-process things, with the Lp=> bit,
// because whisk requires a JSONObject, i.e. JSONArray doesn't count
// plus, we want just the name field
//
exports.main = wrap({ api: 'listContainers',
		      postprocess: Lp => Lp.then(L => ({ containers: L.map(c => c.name) }) )
		    })
