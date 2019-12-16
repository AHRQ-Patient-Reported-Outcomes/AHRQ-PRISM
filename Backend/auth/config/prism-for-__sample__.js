// Environments
// - dev
// - prod

const rootDomain = 'example.com'

const authServerOptions = {
  devAuthServer: {
    awsAccountId: '<AWS Account ID>',
    identityPool: '<AWS Cognito identityPool ID>',
    awsIdpProviderName: `authorization.${rootDomain}`,
    client_id: '<OAuth/Smart Client Id',
    client_secret: '<Oauth/Smart Client Secret>',
    redirect_url: 'http://localhost:3031/callback',
    authServerUrl: `https://authorization.${rootDomain}`,
    authorization_endpoint: `https://authorization.${rootDomain}/oauth/authorize`,
    token_endpoint: `https://authorization.${rootDomain}/oauth/token`,
    jwks_url: `https://authorization.${rootDomain}/oauth/discovery/keys`,
  },

  prodAuthServer: {
    awsAccountId: '<AWS Account ID>',
    identityPool: '<AWS Cognito identityPool ID>',
    awsIdpProviderName: `authorization.${rootDomain}`,
    client_id: '<Oauth/Smart Client ID>',
    client_secret: '<Oauth/Smart Client Secret>',
    redirect_url: `https://auth-lambda.${rootDomain}/callback`,
    authServerUrl: `https://authorization.${rootDomain}/`,
    authorization_endpoint: `https://authorization.${rootDomain}/oauth/authorize`,
    token_endpoint: `https://authorization.${rootDomain}/oauth/token`,
    jwks_url: `https://authorization.${rootDomain}/oauth/discovery/keys`,
    webAppUrl: `https://app.${rootDomain}`
  }
}

const fhirServerOptions = {
  baseUrl: `https://fhir.${rootDomain}`
}

module.exports = {
  authServerOptions,
  fhirServerOptions
}
