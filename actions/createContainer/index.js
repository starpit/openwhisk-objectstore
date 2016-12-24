const ObjectStorage = require('bluemix-objectstorage').ObjectStorage

exports.main = params => new ObjectStorage(params.creds, undefined, params.authToken).createContainer(params.containerName)
