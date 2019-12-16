import { ENV } from './env'

ENV.production = false;
ENV.development = true;

ENV.authLambda.baseUrl = 'http://localhost:3031';
ENV.authLambda.selfUrl = 'http://localhost:8100';

ENV.apiLambda.baseUrl = 'http://localhost:3030';

switch(ENV.envName) {
  case 'my-env-name':
    ENV.identityPoolId = 'us-east-1:abc123';
    ENV.idpProviderName = 'authorization.my-fhir-server.com';
    break;
  default:
    throw 'You must select an envName in env.ts'
}

export { ENV };
