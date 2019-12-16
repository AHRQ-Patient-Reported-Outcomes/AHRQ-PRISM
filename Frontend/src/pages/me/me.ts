import { Component, ViewChild } from '@angular/core';
import { NavController, NavParams } from 'ionic-angular';
import * as _ from 'lodash';

import { AuthProvider } from './../../providers/auth/auth';
import { QuestionnaireProvider } from '../../providers/questionnaire/questionnaire';
import { HistoryProvider } from '../../providers/history/history';
import { PatientProvider } from '../../providers/patient';

import { API } from 'aws-amplify';

@Component({
  selector: 'page-me',
  templateUrl: 'me.html',
})
export class MePage {
  @ViewChild('lineCanvas') lineCanvas;
  graphData: Array<any>;
  mostRecentResponse: any;
  currentPatient: any;

  clickCount: number;
  showControls: boolean;
  isLoggingOut: boolean;

  //Variables to use for chart
  lineChart: any;
  userHistory: any;
  monthData: any;
  testData: any;
  recentScore: any;
  chartColor: string;

  constructor(
    public navCtrl: NavController,
    public navParams: NavParams,
    public authProvider: AuthProvider,
    public questionnaireProvider: QuestionnaireProvider,
    public historyProvider: HistoryProvider,
    public patientProvider: PatientProvider
  ) {
    this.clickCount = 0;
    this.showControls = false;
    this.isLoggingOut = false;
  }

  get patientName() {
    return (`${this.currentPatient.name[0].given[0]} ${this.currentPatient.name[0].family[0]}`).toLowerCase();
  }

  get mostRecentScore() {
    if (this.mostRecentResponse) {
      return Math.round(this.mostRecentResponse.theta * 10 + 50)
    }
  }

  incrementCount() {
    this.clickCount += 1
    if (this.clickCount > 3) {
      this.showControls = true;
    }
  }

  ionViewCanEnter(): boolean | Promise<any>{
    return this.authProvider.isAuthenticated(this.navCtrl).then((isAuthenticated) => {
      // If the response is true, aka we can enter, check for in-progress responses before continuing
      if (isAuthenticated) {
        return this.questionnaireProvider.findInProgressQuestionnaire().then((resp) => {
          if (!resp) { return isAuthenticated; }

          // Go to prequestionnaire-page
          setTimeout(() => { this.navCtrl.push('prequestionnaire-page', { 'id': resp.id }); }, 0);

          return false;
        });
      }

      return isAuthenticated;
    });
  }

  ngAfterViewInit() {
    return this.patientProvider.getCurrentPatient().then((data) => {
      this.currentPatient = data
    }).then(() => {
      return this.historyProvider.getHistory()
    }).then((data) => {
      this.mostRecentResponse = _.orderBy(data, ['date'], ['asc'])[0]

      return this.historyProvider.getGraphScores().then((data) => {
        this.graphData = data;
      });
    });
  }

  resetResponse() {
    API.get('PrismAPI',
      `/QuestionnaireResponses/${this.mostRecentResponse.id}/reset`,
      {}
    ).then(() => {
      console.log('reset latest questionnaire response')
      this.questionnaireProvider.checkedInProgress = false;
      this.questionnaireProvider.findInProgressQuestionnaire().then((resp) => {
        if (!resp) { return; }

        console.log('reset response', resp)
        // Go to prequestionnaire-page
        setTimeout(() => { this.navCtrl.push('prequestionnaire-page', { 'id': resp.id }); }, 0);
      });
    }).catch((err) => {
      console.log(err)
      window.alert('Failed to reset')
    })
  }

  logOut() {
    this.isLoggingOut = true;
    this.authProvider.logOut()
  }

  goToHistory() {
    this.navCtrl.push('HistoryPage', {
      graphData: this.graphData,
      currentPatient: this.currentPatient,
      mostRecentResponse: this.mostRecentResponse
    });
  }

  goToPatientStories() {
    console.log('PATIENT STORIES!');
  }

  goToArticles() {
    this.navCtrl.push('ArticlesPage');
  }

  goToQuestionnaire() {
    this.navCtrl.push('prequestionnaire-page');
  }

  download() {
    this.navCtrl.push('DownloadPage');
  }
}
