# The PRISM Frontend App
The PRISM frontend web and mobile app is built using ionic and angular. This allows us to use one codebase and deploy on iOS, Android and Web. 

# Project Setup
### Prerequisites
The PRISM app depends on the following tools and frameworks to develop and distribute. Before you begin installing the project, please ensure that the follow are installed:
1. Node & npm -- https://nodejs.org/en/download/
2. Ionic -- `npm install -g ionic`
3. Xcode & Xcode Tools `xcode-select --install`
4. Java -- https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
5. Gradle -- https://gradle.org/install/
6. Android Studio -- https://developer.android.com/studio/install

### Configuration & Installations
The PRISM frontend relies on the PRISM Backend and the AWS Services that compose it. Before building the application we must set configure the environment and install dependencies.

1. In `./src/env/env.dev.ts', set the `identityPoolId` and the url of the authorization server.
2. In `./src/env/env.prod.ts', set the:
    - `identityPoolId` 
    - url of the authorization server
    - URL of the apiLambda function
    - URL of the authLambda function
    - URL where the web version is hosted (This is the redirect url registered with auth server)
3. `npm install`
4. `ionic cordova prepare ios`
5. `ionic cordova prepare android`

### Development
The PRISM frontend is relatively simple. To build it for development in a web browser, run:
1. `npm install && npm run-script start`

To build and test in iOS simulator, run:
1. `npm install && ionic cordova build ios`
2. Open the project's xcworkspace using XCode. `./platforms/ios/PRISM.xcworkspace`
3. In xcode, File => WorkSpace Settings => Use legacy build system
4. Select the simulator you want and then build

### Releasing to the App Store (iOS)
```bash
ionic cordova build ios --prod --release
```

Move to XCode and archive the app then upload to app store. More documentation: https://ionicframework.com/docs/publishing/app-store

### Releasing to the App Store (Android)
```bash
ionic cordova build android --prod --release
```

Then follow the steps here to sign and upload to Play Store: https://ionicframework.com/docs/publishing/play-store
