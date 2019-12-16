import { Component } from '@angular/core';
import { NavController, NavParams } from 'ionic-angular';

@Component({
  selector: 'page-download',
  templateUrl: 'download.html',
})
export class DownloadPage {

  constructor(public navCtrl: NavController, public navParams: NavParams) {
  }

  ionViewDidLoad() {
    console.log('ionViewDidLoad DownloadPage');
  }

  openiOS() {
    console.log('IOS!');
  }

  openAndroid() {
    console.log('ANDROID!');
  }

}
