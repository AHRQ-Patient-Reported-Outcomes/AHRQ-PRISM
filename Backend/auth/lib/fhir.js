const providers = require('./fhir-client/providers');
const authorize = require('./fhir-client/authorize');
const adapter = require('./fhir-client/adapter');

const getAccessToken = require('./fhir-client/get-access-token');
const getRefreshToken = require('./fhir-client/get-refresh-token');
const getPatient = require('./fhir-client/get-patient');

const FHIR = {
  config: {
    auth_uri: null,
    token_uri: null
  },
  adapter: adapter,
  providers: providers,
  authorize: authorize,
  getAccessToken: getAccessToken,
  getPatient,
  getRefreshToken,
}

module.exports = FHIR
