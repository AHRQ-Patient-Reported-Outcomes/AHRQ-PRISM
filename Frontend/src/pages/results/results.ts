import { Component } from '@angular/core';
import { NavController, NavParams, ModalController, Platform } from 'ionic-angular';
import { ResultsModalPage } from './../results-modal/results-modal';

import { QuestionnaireProvider } from './../../providers/questionnaire/questionnaire';

// Interfaces
import {
  QuestionnaireResponse,
  populationComparison
} from '../../models/questionnaire-response';
import { Questionnaire } from '../../models/questionnaire';

@Component({
  selector: 'page-results',
  templateUrl: 'results.html',
})
export class ResultsPage {
  questionnaireResponse: QuestionnaireResponse;
  questionnaire: Questionnaire;
  title: any;
  score: any;
  description: any;
  comparison: any;
  modalDiff: any;
  modalTimeSinceLast: any;

  highestYet: any;
  lowestYet: any;

  constructor(
    public navCtrl: NavController,
    public navParams: NavParams,
    public modalCtrl: ModalController,
    public questionnaireProvider: QuestionnaireProvider,
    public platform: Platform
    ) {
    this.questionnaireProvider.findQuestionnaireResponse(navParams.data.id, true).then((questResp) => {
      this.questionnaireResponse = questResp;

      this.questionnaire = this.questionnaireResponse.contained.find((c) => {
        return c['resourceType'] === 'Questionnaire';
      })

      this.score = Number((this.questionnaireResponse.theta * 10) + 50).toFixed(0);
      const containedQr = this.questionnaireResponse.contained[0]
      this.title = (containedQr.description || containedQr.title);
      this.description = this.scoreInWords(this.score);
      this.comparison = populationComparison(this.questionnaireResponse);

      if(this.questionnaireResponse.result_modal_data) {
        this.modalDiff = Number(this.questionnaireResponse.result_modal_data.diff);
        this.modalTimeSinceLast = Number(this.questionnaireResponse.result_modal_data.timeSinceLast)

        this.highestYet = this.questionnaireResponse.result_modal_data.isHighestEver
        this.lowestYet = this.questionnaireResponse.result_modal_data.isLowestEver
      }

      if(this.questionnaireResponse.result_modal_data && Math.abs(this.modalDiff) > 1) {
        setTimeout(() => {
          this.presentModal();
        }, 2000);
      }
    });
  }

  ionViewDidLoad() {
    console.log('ionViewDidLoad ResultsPage');
  }

  goToHome() {
    console.log('Platform: ', this.platform.platforms());
    if (window.cordova) {
      //User already has the app, take them to the MePage
      this.navCtrl.push('MePage');
    } else {
      //User need to download the app
      this.navCtrl.push('DownloadPage');
    }

    //Comment out the above, and uncomment the below for testing purposes
    // this.navCtrl.push('MePage');
  }

  scoreInWords(score: number) {
    if (score > 58) { return 'Excellent' }
    else if (50 < score && score <= 58) { return 'Very Good'}
    else if (43 < score && score <= 50) { return 'Good'}
    else if (35 < score && score <= 43) { return 'Fair'}
    else if (score <= 35) { return 'Poor'}
  }

  async presentModal() {
    const modal = this.modalCtrl.create(ResultsModalPage, {
      scoreDifference: this.modalDiff,
      timeSinceLast: this.modalTimeSinceLast,
      highestYet: this.questionnaireResponse.result_modal_data.isHighestEver,
      lowestYet: this.questionnaireResponse.result_modal_data.isLowestEver
    }, {
      enterAnimation: 'modal-enter',
      leaveAnimation: 'modal-leave',
      enableBackdropDismiss: true
    });
    modal.present();
  }
}
