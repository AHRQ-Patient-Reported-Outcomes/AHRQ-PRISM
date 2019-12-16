const axios = require('axios');
const qs = require('qs');
const { ENV } = require('../../config/environment');
const jose = require('node-jose');

module.exports = (fhirAccessData) => {
  var api_server_uri = ENV.fhirServer.baseUrl;
  var patient_id     = 'abc_123';
  var access_token   = fhirAccessData.access_token;
  var url            = api_server_uri + '/Patient/' + patient_id;

  return decodeJwt(fhirAccessData.id_token).then((result) => {
    // Decode the JWT to get the URL of the fhirUser to query.

    return axios({
      method: 'get',
      url: api_server_uri + result.fhirUser,
      headers: {
        'Authorization': `Bearer ${access_token}`
      }
    }).then((response) => {
      return response.data;
    });
  });
}

// verify
const decodeJwt = async jwt => {
  let keystore = jose.JWK.createKeyStore();
  try {
    let jwks = ENV.oauthInfo.provider.jwks;
    if (!jwks) {
      jwks = await ENV.oauthInfo.provider.getJWKs();
      ENV.oauthInfo.provider.jwks = jwks;
    }
    keystore = await jose.JWK.asKeyStore(jwks);
    const result = await jose.JWS.createVerify(keystore).verify(jwt);
    return JSON.parse(result.payload.toString());
  } catch (e) {
    return null;
  }
};
