const axios = require('axios');

// minnesota, medstar or cerner, __sample__
// This will lookup a file in the same directory called `prism-for-envName.js` and
// load the configuration from there.
const envName = '__sample__'
const { authServerOptions, fhirServerOptions } = require(`./prism-for-${envName}`)

const getJWKs = async jwks_url => {
  try {
    const response = await axios.get(jwks_url);
    return response.data;
  } catch (e) {
    return null;
  }
};

var buildOauthInfo = (data) => {
  return {
    client: {
      'client_id': data.client_id,
      'client_secret': data.client_secret,
      'scope': 'patient/Patient.* patient/QuestionnaireResponse.* patient/Questionnaire.* openid fhirUser offline_access',
      'redirect_uri': data.redirect_url
    },
    'server': data.authServerUrl,
    'provider': {
      authorize_uri: data.authorization_endpoint,
      token_url: data.token_endpoint,
      jwks: null,
      getJWKs: () => getJWKs(data.jwks_url),
    },
    awsConfig: {
      accountId: data.awsAccountId,
      idpName: data.awsIdpProviderName,
      identityPoolId: data.identityPool,
    }
  }
}

let ENV = {
  oauthInfo: null,
  webappUrl: null,
  dynamoDbTableName: 'PrismApiTable',
  currentQuestionnaireId: 'questionnaire_80c5d4a3-fc1f-4c1b-b07e-10b796cf8105',
  alternativeQuestionnaireId: 'questionnaire_154D0273-C3F6-4BCE-8885-3194D4CC4596'
}

if (process.env.NODE_ENV === 'production') {
  ENV.oauthInfo = buildOauthInfo(authServerOptions['prodAuthServer']),
  ENV.webappUrl = authServerOptions['prodAuthServer']['webAppUrl'],
  ENV.fhirServer = fhirServerOptions
} else {
  ENV.oauthInfo = buildOauthInfo(authServerOptions['devAuthServer']),
  ENV.webappUrl = 'http://localhost:8100',
  ENV.fhirServer = fhirServerOptions
}

module.exports = {
  ENV,
};
