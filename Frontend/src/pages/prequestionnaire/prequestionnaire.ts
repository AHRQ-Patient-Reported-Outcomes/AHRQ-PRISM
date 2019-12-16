import { Component } from '@angular/core';
import { NavController, NavParams } from 'ionic-angular';
import { AuthProvider } from './../../providers/auth/auth';
import { QuestionnaireProvider } from './../../providers/questionnaire/questionnaire';

@Component({
  selector: 'page-prequestionnaire',
  templateUrl: 'prequestionnaire.html'
})
export class PrequestionnairePage {
  title: string;

  constructor(
    public navCtrl: NavController,
    public navParams: NavParams,
    public authProvider: AuthProvider,
    public questionnaireProvider: QuestionnaireProvider
  ) {
    this.title = '';
    this.questionnaireProvider.findQuestionnaireResponse(navParams.data.id).then((questResp) => {
      if (
        Array.isArray(questResp.contained) &&
        questResp.contained.length > 0
      ) {
        this.title = (questResp.contained[0].description || questResp.contained[0].title);
      }
    });
  }

  ionViewCanEnter(): boolean | Promise<any>{
    return this.authProvider.isAuthenticated(this.navCtrl);
  }

  beginAssessment() {
    this.navCtrl.push('questionnaire-page', {id: this.navParams.data.id});
  }

}
