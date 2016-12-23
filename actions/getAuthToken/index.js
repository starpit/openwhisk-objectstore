const ObjectStorage = require('bluemix-objectstorage').ObjectStorage

exports.main = params => {
    return new Promise((resolve, reject) => {
	console.log("A0")
	const os = new ObjectStorage(params.creds)

	try {
	    console.log("A1")
	    return os.client.refreshToken()
		.then(() => {
		    console.log("A2", os.client.authToken)
		    resolve(os.client.authToken)
		})
		.catch(reject)

	} catch (err) {
	    reject(err)
	}
    })
}
