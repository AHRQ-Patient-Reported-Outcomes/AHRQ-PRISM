import { ENV } from './env'

ENV.production = true;
ENV.development = false;

switch(ENV.envName) {
  case 'my-env-name':
    ENV.identityPoolId = 'us-east-1:ABC123';
    ENV.apiLambda.baseUrl = 'api-lambda-url';
    ENV.authLambda.baseUrl = 'auth-lambda-url';
    ENV.authLambda.selfUrl = 'domain-that-this-is-hosted-at.com';
    ENV.idpProviderName = 'url-of-auth-server';
    break;
  default:
    throw 'You must select an envName in env.ts'
}

export { ENV }
