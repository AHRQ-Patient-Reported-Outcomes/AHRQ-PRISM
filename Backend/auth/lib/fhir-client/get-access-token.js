const axios = require('axios');
const qs = require('qs');
const { ENV } = require('../../config/environment');

// returns
// fhirAccessData:  {
//   access_token: 'the_token',
//   refresh_token: 'refresh_token',
//   patient: '4342008',
//   scope: 'patient/Patient.read patient/Observation.read launch/patient online_access openid profile',
//   id_token: 'id_token',
//   token_type: 'Bearer',
//   expires_in: 570
// }
module.exports = function(code, clientId) {
  const data = {
    postData: qs.stringify({
      code: code,
      redirect_uri: ENV.oauthInfo.client.redirect_uri,
      client_id: clientId,
      client_secret: ENV.oauthInfo.client.client_secret,
      grant_type: 'authorization_code'
    }),
    uri: ENV.oauthInfo.provider.token_url
  }

  return axios({
    method: 'post',
    url: data.uri,
    data: data.postData,
    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' }
  }).then(data => data.data);
};
