import { ENV } from '@env'

import { BehaviorSubject } from "rxjs/Rx";
import { Injectable } from '@angular/core';
import { NavController, Platform } from 'ionic-angular';

// import is

// import { InAppBrowser } from '@ionic-native/in-app-browser/ngx';

// Amplify
import { Auth } from 'aws-amplify';

// Providers
import { ApiClient } from "../api-client";
import { AwsProvider, awsCredentials } from '../aws/aws';

// Interface
import { Patient } from '../../models/patient';

interface AuthResponse {
  awsIdentityId: string;
  fhirAccessToken: string;
  fhirExpiresIn: number;
  patient: Patient;
}

@Injectable()
export class AuthProvider {
  public apiName = 'PrismAPI';
  public authResponse: AuthResponse;
  public authStatus$: BehaviorSubject<string>;
  public loggedIn: boolean;
  private apiClient: ApiClient;
  private awsProvider: AwsProvider;

  constructor(
    apiClient: ApiClient,
    awsProvider: AwsProvider,
    private cdvPlatform: Platform
  ) {
    this.apiClient = apiClient;
    this.awsProvider = awsProvider;
    this.loggedIn = false;

    // Auth.configure({
    //   refreshHandlers: {
    //     [ENV.idpProviderName]: this.refreshTheToken
    //   }
    // });

    this.authStatus$ = new BehaviorSubject('initial');
  }

  // returns a promise
  public currentUser(reload = true) : Promise<any> {
    return Auth.currentAuthenticatedUser().then((user) => {
      return Auth.currentUserCredentials().then((creds) => {
        return user;
      });
    }).catch((err) => {
      // Sometimes we want to check if there is a user but don't want to reload
      if (reload) { this.logOut(); }

      return false;
    });
  }

  // Clear session and log out.
  public logOut() : Promise<void> {
    return Auth.signOut().then(() => {
      return this.authServerLogout();
    }).then(() => {
      this.loggedIn = false;
      localStorage.clear();
      window.location.replace('/');
    })
  }

  public isAuthenticated(nav: NavController): Promise<boolean> {
    return this.currentUser().then((user) => {
      if (user) {
        this.loggedIn = true;
        return true;
      }

      return this.logOut().then(() => false)
    });
  }

  // ======================================
  // Login Methods:
  //  - beginLogin
  //  - continueLogin
  //  - assumeFederatedIdentity
  //  - cordovaLogin
  //  - resetStatus
  // ======================================

  // Start Over
  public resetStatus() {
    this.authStatus$.next('initial');
  }

  // Redirect to EHR Auth URL
  public beginLogin() : void {
    this.authStatus$.next('beginning');

    // We want to wait for a small amount of time before
    // taking the user to the login page.
    setTimeout(() => {
      if (this.cdvPlatform.is('cordova')) {
        // Use the InAppBrowser to login
        this.cordovaLogin();
      } else {
        // regular web browser
        window.location.href = ENV.authLambda.launchUrl();
      }
    }, 1500)
  }


  // Go back to authLambda and get access token and patient data
  public async continueLogin(params) : Promise<void> {
    this.authStatus$.next('continueLogin');
    try {
      // Post the auth code and state to the backend token endpoint to retrieve our
      // identity and access tokens
      this.authResponse = await this.apiClient.post<AuthResponse>({
        url: ENV.authLambda.tokenUrl(),
        params: params
      })

      // Not sure why I do this
      window.history.replaceState({}, document.title, '/');

      // Now that we have the id_token from fhir server, we can get our
      // AWS credentials
      this.assumeFederatedIdentity();
    } catch(e) {
      console.log('login failed');
      console.log(e)

      // Do the logout and redirect
      this.logOut();
    }
  }

  // Auth.currentAuthenticatedUser().then(user => console.log(user));
  // Auth.currentCredentials().then(creds => console.log(creds));
  private assumeFederatedIdentity() : void {
    const result = this.authResponse;

    // Calculate when the token expires
    const date = new Date();
    const expires_at = result.fhirExpiresIn * 1000 + date.getTime();

    const patient = result.patient;
    const nameData = patient.name.find((i) => i.use === 'official' );

    const user = {
      patient_id: patient.id,
      name: [nameData.given[0], nameData.family[0]].join(' ')
    }

    Auth.federatedSignIn(
      ENV.idpProviderName,
      {
        token: result.fhirAccessToken,
        expires_at
      },
      user
    ).then((credentials) => {
      // At this point we're done with our login process
      this.loggedIn = true;
      this.authStatus$.next('done');
      this.awsProvider.setCredentials(credentials as awsCredentials);
    }).catch((e) =>{
      window.alert("We're sorry, something went wrong");
      console.log(e);

      this.logOut();
    });
  }

  // Perform login via InAppBrowser.
  // This is only for when we're in cordova
  private cordovaLogin() {
    const startUrl = ENV.authLambda.launchUrl();

    // @ts-ignore
    const successUrlRegx = new RegExp(`${ENV.authLambda.selfUrl}`);

    // @ts-ignore
    var browser = window.cordova.InAppBrowser.open(startUrl, '_blank', 'location=no');

    // On each page load, check if we've been redirected back to our redirectUrl
    browser.addEventListener('loadstart', (event) => {
      if (event.url.match(successUrlRegx)) {
        // close the browser, we are done!
        this.authStatus$.next('closing');
        browser.close();

        const params = new URL(event.url).searchParams;

        this.continueLogin({
          'code': params.get('code'),
          'state': params.get('state')
        });
      }
    });

    // Catch the close event if login failed and redirect
    // to the home page.
    browser.addEventListener('exit', event => {
      if (
        this.authStatus$.value !== 'closing' &&
        this.authStatus$.value !== 'continueLogin'
      ) {
        this.logOut();
      }
    });
  }

  private authServerLogout() : Promise<boolean> {
    if (this.cdvPlatform.is('cordova')) {
      // Use the InAppBrowser to login
      return this.cordovaLogOut();
    } else {
      return this.apiClient.get({
        url: `https://${ENV.idpProviderName}/accounts/sign_out`,
        withCredentials: true
      }).then(() => true).catch((e) => {
        console.log('error', e)
        // Continue onwards
        return true;
      })
    }
  }

  private cordovaLogOut() : Promise<boolean> {
    console.log('cordovaLogOut');
    return new Promise((resolve) => {
      const url = `https://${ENV.idpProviderName}/accounts/sign_out`

      const options = [
        'location=no',
        'hidden=yes',
        'usewkwebview=yes'
      ].join(',')

      // @ts-ignore
      const browser = window.cordova.InAppBrowser.open(url, '_blank', options);

      browser.addEventListener('loadstop', () => {
        browser.close();
      });

      browser.addEventListener('exit', () => {
        resolve(true);
      })
    })
  }

  // private async refreshTheToken() {
  //   let that = this;
  //   console.log(that)
  //   return API.post('AuthApi', '/refresh', {}).then((refreshData) => {
  //     console.log('successful refresh')
  //     const date = new Date();
  //     const expires_at = refreshData.fhirExpiresIn * 1000 + date.getTime();

  //     return {
  //       token: refreshData.fhirIdToken,
  //       expires_at,
  //     };
  //   }).catch((err) => {
  //     console.log('foobar')
  //     console.log(err);
  //     that.logOut();

  //     return null;
  //   })
  // }
}
