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
