import { Component } from '@angular/core';
import { NavController, NavParams, ViewController } from 'ionic-angular';

@Component({
  selector: 'page-results-modal',
  templateUrl: 'results-modal.html',
})
export class ResultsModalPage {
  scoreDifference: any;
  scoreDifferenceAbs: any;
  timeSinceLast: any;
  isPositive: boolean;

  constructor(
    public navCtrl: NavController,
    public navParams: NavParams,
    public viewCtrl: ViewController)
    {
      this.scoreDifference = navParams.get('scoreDifference');
      this.scoreDifferenceAbs = Math.abs(navParams.get('scoreDifference'));
      this.timeSinceLast = navParams.get('timeSinceLast');

      if (this.scoreDifference >= 0) {
        this.isPositive = true;
      } else {
        this.isPositive = false;
      }

      // setTimeout(() => {
      //   this.dismiss();
      // },5000)
    }

  ionViewDidLoad() {
    console.log('ionViewDidLoad ResultsModalPage');
  }

  dismiss() {
    this.viewCtrl.dismiss();
  }

}
