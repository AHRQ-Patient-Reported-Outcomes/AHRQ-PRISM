import { ENV } from '@env';

export default {
  Auth: {

    // REQUIRED only for Federated Authentication - Amazon Cognito Identity Pool ID
    identityPoolId: ENV.identityPoolId,

    // REQUIRED - Amazon Cognito Region
    region: 'us-east-1',

    // OPTIONAL - Amazon Cognito Federated Identity Pool Region
    // Required only if it's different from Amazon Cognito Region
    identityPoolRegion: 'us-east-1',

    // OPTIONAL - Enforce user authentication prior to accessing AWS resources or not
    mandatorySignIn: true,

    // OPTIONAL - Manually set the authentication flow type. Default is 'USER_SRP_AUTH'
    authenticationFlowType: 'USER_PASSWORD_AUTH'
  },

  API: {
    endpoints: [
      {
        name: 'PrismAPI',
        endpoint: ENV.apiLambda.baseUrl
      },
      {
        name: 'AuthApi',
        endpoint: ENV.authLambda.baseUrl
      }
    ]
  }
}
