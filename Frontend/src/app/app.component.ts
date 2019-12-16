import { ENV } from '@env';

import { Component } from '@angular/core';
import { Platform, Config } from 'ionic-angular';
import { StatusBar } from '@ionic-native/status-bar';
import { SplashScreen } from '@ionic-native/splash-screen';

import amplifyConfig from '../amplify-config';
import { Auth, API, Analytics } from 'aws-amplify';

import { AutoLogout } from '../auto-logout';
import { AuthProvider } from '../providers/auth/auth';

import { myEnterAnimation } from './../app/animations/enter';
import { myLeaveAnimation } from './../app/animations/leave';

import 'offline-js';

// import { MePage } from '../pages/me/me';
@Component({
  templateUrl: 'app.html'
})
export class MyApp {
  rootPage: any;
  pages: any[] = [
    { title: 'Me', component: 'MePage' },
    { title: 'Welcome', component: 'WelcomePage' }
  ]

  constructor(
    platform: Platform,
    statusBar: StatusBar,
    splashScreen: SplashScreen,
    public authProvider: AuthProvider,
    public config: Config,
    private autoLogout: AutoLogout

  ) {
    Auth.configure(amplifyConfig);
    API.configure(amplifyConfig);
    Analytics.configure({ disabled: true })

    // @ts-ignore
    window.Offline.options = {
      requests: false,
      checks: {
        xhr: {
          url: `https://${ENV.idpProviderName}/healthcheck`
        }
      }
    };

    platform.ready().then(() => {
      // Okay, so the platform is ready and our plugins are available.
      // Here you can do any higher level native things you might need.
      statusBar.styleDefault();
      splashScreen.hide();

      // On init, decide where we should route the user
      this.authProvider.currentUser(false).then((user) => {
        if (user) {
          // Do not load me page twice
          if (!window.location.href.match(/\/me/)) {
            this.rootPage = 'MePage';
          }
        } else {
          // We do not want to load the authpage twice
          if (window.location.href.match(/\/auth/)) {
            // Do nothing. It will go to auth page and everything will work nicely.
          } else if (!window.location.href.match(/\/welcome/)) {
            this.rootPage = 'WelcomePage';
          }
        }
      })
    });

    //Used to set custom modal transition
    this.setCustomTransitions();
  }

  private setCustomTransitions() {
    this.config.setTransition('modal-enter', myEnterAnimation);
    this.config.setTransition('modal-leave', myLeaveAnimation);
  }
}

