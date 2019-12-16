const AWS = require('aws-sdk');
const { ENV } = require('../../config/environment');
const cognitoidentity = new AWS.CognitoIdentity();

module.exports = async function(fhirAccessData){
  const fhirIdToken = fhirAccessData.id_token;

  const awsIdentity = await getAwsId(fhirIdToken);
  const awsAccessData = await getAwsCredentials(awsIdentity, fhirIdToken);

  return awsAccessData;
}

const awsRegion = 'us-east-1'
const awsParams = (id_token) => {
  let login_data = {}
  login_data[ENV.oauthInfo.awsConfig.idpName] = id_token

  return {
    IdentityPoolId: ENV.oauthInfo.awsConfig.identityPoolId,
    AccountId: ENV.oauthInfo.awsConfig.accountId,
    Logins: login_data
  };
}

// Get the Cognito ID
// Returns: {
//    "IdentityId": "string"
// }
const getAwsId = async function(fhirIdToken) {
  return new Promise(function(resolve, reject) {
    cognitoidentity.getId(awsParams(fhirIdToken), function(err, data) {
      if (err) { reject(err) } else { resolve(data) }
    });
  });
}

// Get the AWS credentials for the ID
// Response Syntax:
// {
//    "Credentials": {
//       "AccessKeyId": "string",
//       "Expiration": number,
//       "SecretKey": "string",
//       "SessionToken": "string"
//    },
//    "IdentityId": "string"
// }
const getAwsCredentials = async function(awsIdentity, fhirIdToken) {
  return new Promise((resolve, reject) => {
    let login_data = {}
    login_data[ENV.oauthInfo.awsConfig.idpName] = fhirIdToken

    cognitoidentity.getCredentialsForIdentity({
      IdentityId: awsIdentity.IdentityId,
      Logins: login_data
    }, function(err, data) { if (err) { reject(err) } else { resolve(data) } });
  });
}
