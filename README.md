# OpenWhisk package for Bluemix ObjectStore

This repository houses an OpenWhisk package for the Bluemix ObjectStore.

## Prerequisites

 1. [install the `wsk` CLI](https://bluemix.net/openwhisk/cli). 
 2. [install the `cf` CLI](https://github.com/cloudfoundry/cli/releases)
 3. Make sure you have an ObjectStore instance set up. Make note of
    the name of your service instance (referred to as OS_INSTANCE
    below).
 4. Make sure you have a service key for your instance, and make
    note of the name of this key (referred to as OS_KEY below).

## ObjectStore How-To
  
If you'd like to set up an ObjectStore instance, follow these
steps. For this example, let's assume you name your service instance
"documents", and your service key "testclient".

 1. `cf create-service Object-Storage standard documents`
 2. `cf create-service-key documents testclient`
	
## Example Usage

```
% ./init.sh $OS_INSTANCE $OS_KEY
% wsk action invoke objectstore/getAuthToken --blocking --result
{
    "expiration": "2016-12-24T15:22:47.764396Z",
    "token": "xxxxxx"
}
```
