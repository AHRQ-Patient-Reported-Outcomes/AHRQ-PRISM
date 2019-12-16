export const ENV = {
  production: null,
  development: null,

  identityPoolId: null,
  idpProviderName: null,
  envName: 'my-env-name',

  apiLambda: {
    baseUrl: null
  },

  authLambda: {
    baseUrl: null, // set in environment config
    selfUrl: null, // set per environment. Used for checking redirect url
    launchPath: '/launch',
    tokenPath: '/token',
    launchUrl() {
      return this.baseUrl + this.launchPath;
    },

    tokenUrl() {
      return this.baseUrl + this.tokenPath;
    }
  }
};
