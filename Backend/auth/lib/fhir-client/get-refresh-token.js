const axios = require('axios');
const qs = require('qs');
const { ENV } = require('../../config/environment');

module.exports = function(access_token, refresh_token) {
  const headers = {
    'Authorization': `Bearer ${access_token}`,
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
  };
  const data = qs.stringify({
    grant_type: 'refresh_token',
    refresh_token,
    client_id: ENV.oauthInfo.client.client_id,
    client_secret: ENV.oauthInfo.client.client_secret,
  });

  return axios({
    method: 'post',
    url: ENV.oauthInfo.provider.token_url,
    data,
    headers
  }).then(data => data.data);
};
