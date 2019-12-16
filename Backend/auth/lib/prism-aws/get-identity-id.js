module.exports = function(req){
  const headers = req.headers
  console.log('headers', headers)

  const apiGatewayEvent = JSON.parse(decodeURIComponent(headers['x-apigateway-event']))
  console.log('apiGatewayEvent', apiGatewayEvent)

  const requestContext = apiGatewayEvent['requestContext']
  console.log('requestContext', requestContext)

  const identity = requestContext['identity']
  console.log('identity', identity)

  const cognitoIdentityId = identity['cognitoIdentityId']
  console.log('cognitoIdentityId', cognitoIdentityId)

  return cognitoIdentityId;
}
