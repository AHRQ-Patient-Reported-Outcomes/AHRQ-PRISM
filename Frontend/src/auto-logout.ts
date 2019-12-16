import * as store from 'store';

import { Injectable, NgZone } from '@angular/core';
import { AuthProvider } from './providers/auth/auth';
import { Platform } from 'ionic-angular';

const MINUTES_UNITL_AUTO_LOGOUT = 60 // in mins
const CHECK_INTERVAL = 1000 // in ms
const STORE_KEY =  'lastAction';

@Injectable()
export class AutoLogout {
  constructor(
    private auth: AuthProvider,
    private ngZone: NgZone,
    private platform: Platform
  ) {
    this.check();
    this.reset();
    this.initListener();
    this.initInterval();
  }

  get lastAction() {
    return parseInt(store.get(STORE_KEY));
  }
  set lastAction(value) {
    store.set(STORE_KEY, value);
  }

  initListener() {
    this.ngZone.runOutsideAngular(() => {
      document.body.addEventListener('click', () => this.reset());

      document.addEventListener('visibilitychange', () => {
        if (!document.hidden) { this.check(); }
      }, false);

      if (this.platform.is('cordova')) {
        // Standard Cordova Events
        document.addEventListener('resume', () => this.check());
        document.addEventListener('pause', () => this.check());

        // iOS Specific events.
        // Resign is when app is in foreground and lock button pressed
        document.addEventListener('resign', () => this.check());
        // Active is when app is in foreground and device is unlocked
        document.addEventListener('active', () => this.check());
      }
    });
  }

  initInterval() {
    this.ngZone.runOutsideAngular(() => {
      setInterval(() => {
        this.check();
      }, CHECK_INTERVAL);
    })
  }

  reset() {
    this.lastAction = Date.now();
  }

  check() {
    const now = Date.now();
    const timeleft = this.lastAction + MINUTES_UNITL_AUTO_LOGOUT * 60 * 1000;
    const diff = timeleft - now;
    const isTimeout = diff < 0;

    this.ngZone.run(() => {
      if (isTimeout && this.auth.loggedIn) {
        this.auth.logOut();
      }
    });
  }
}
