const ObjectStorage = require('bluemix-objectstorage').ObjectStorage

exports.main = params => {
    return new Promise((resolve, reject) => {
	const os = new ObjectStorage(params.creds)

	try {
	    os.client.refreshToken()
		.then(() => {
		    resolve(os.client.authToken)
		})
		.catch(reject)

	} catch (err) {
	    reject(err)
	}
    })
}
