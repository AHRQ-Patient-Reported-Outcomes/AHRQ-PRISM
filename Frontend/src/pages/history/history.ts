import { Component } from '@angular/core';
import { NavController, NavParams, LoadingController } from 'ionic-angular';
import { AuthProvider } from '../../providers/auth/auth';
import { HistoryProvider } from '../../providers/history/history';
import {
  QuestionnaireResponse,
  populationComparison
} from '../../models/questionnaire-response';

import * as moment from 'moment';
import * as _ from 'lodash';

@Component({
  selector: 'page-history',
  templateUrl: 'history.html',
})
export class HistoryPage {
  //Variables that are used on this view to display data
  mostRecentResponse: QuestionnaireResponse;
  historyData: any;
  recentDate: any;
  recentDescription: any;
  recentComparison: any;
  chartColor: string;

  //Variables that are passed to this view, from the Me Page
  graphData: Array<any>;
  currentPatient: any;

  get mostRecentScore() {
    if (this.mostRecentResponse) {
      return Math.round(this.mostRecentResponse.theta * 10 + 50)
    }
  }

  constructor(
    public navCtrl: NavController,
    public navParams: NavParams,
    public authProvider: AuthProvider,
    public historyProvider: HistoryProvider,
    public loadingCtrl: LoadingController
  ) {
    //Get the variables passed into this view from Me Page
    this.graphData = navParams.get('graphData');
    this.currentPatient = navParams.get('currentPatient'); //used directly in the html
    this.mostRecentResponse = navParams.get('mostRecentResponse'); //used directly in the html
    this.chartColor = "pink";

    this.historyData = _.orderBy(this.graphData, ['date'], ['desc']).map((obj) => { return obj; });

    this.recentDate = moment(this.mostRecentResponse.authored).format('MMM D, YYYY')
    this.recentComparison = populationComparison(this.mostRecentResponse);
  }

  ionViewCanEnter(): boolean | Promise<any>{
    return this.authProvider.isAuthenticated(this.navCtrl);
  }

  scoreInWords(score: number) {
    if (score > 58) { return 'Excellent' }
    else if (50 < score && score <= 58) { return 'Very Good'}
    else if (43 < score && score <= 50) { return 'Good'}
    else if (35 < score && score <= 43) { return 'Fair'}
    else if (score <= 35) { return 'Poor'}
  }

  goBack() {
    // let loader = this.loadingCtrl.create({
    //   dismissOnPageChange: true
    // });
    // loader.present();
    this.navCtrl.pop();
  }
}
