/*
 * The webpack config exports an object that has a valid webpack configuration
 * For each environment name. By default, there are two Ionic environments:
 * "dev" and "prod". As such, the webpack.config.js exports a dictionary object
 * with "keys" for "dev" and "prod", where the value is a valid webpack configuration
 * For details on configuring webpack, see their documentation here
 * https://webpack.js.org/configuration/
 */

const path = require('path');
const { dev, prod } = require('@ionic/app-scripts/config/webpack.config');
const webpackMerge = require('webpack-merge');

// If you start your building process with the flag --prod this will equal "prod" otherwise "dev"
const ENV = process.env.IONIC_ENV;

console.log('Building with environment: ', ENV)

const devConfig = {
  resolve: {
    alias: {
      "@env": path.resolve(`./src/env/env.dev.ts`)
    }
  }
};

const prodConfig = {
  resolve: {
    alias: {
      // this distincts your specific environment "dev" and "prod"
      "@env": path.resolve(`./src/env/env.prod.ts`)
    }
  }
};

module.exports = {
  dev: webpackMerge(dev, devConfig),
  prod: webpackMerge(prod, prodConfig)
}
