import { Component, ChangeDetectorRef } from '@angular/core';
import { NavController } from 'ionic-angular';
import { AuthProvider } from '../../providers/auth/auth';

// Pages
interface URL {
  searchParams: any;
  [ key: string ]: any;
}

@Component({
  selector: 'page-auth',
  templateUrl: 'auth.html'
})
export class AuthPage {
  currentAuthStatus: string;
  loader: any;

  constructor(
    public navCtrl: NavController,
    public authProvider: AuthProvider,
    private _changeDetector: ChangeDetectorRef
  ) {
    this.currentAuthStatus = 'beginning'
    // this.currentAuthStatus = 'initial';

    authProvider.authStatus$.subscribe({
      next: ((v) => {
        console.log('Status Changed! ', v)
        this.currentAuthStatus = v;

        if (v === 'done') {
          this.navCtrl.push('MePage');
        }

        if (v === 'forceclose') {
          this.authProvider.resetStatus();
          this.navCtrl.popToRoot();
        }

        if (v === 'continueLogin') {
          this._changeDetector.detectChanges();
        }
      })
    });
  }

  ionViewDidLoad() {
    if (window.location.search.match(/code/)) {
      const newUrl: URL = new URL(window.location.href);
      const params = newUrl.searchParams;
      const data = {
        'code': params.get('code'),
        'state': params.get('state')
      }

      this.authProvider.continueLogin(data);
    } else {
      console.log('no code, redirecting')
      this.authProvider.beginLogin();
    }
  }
}
