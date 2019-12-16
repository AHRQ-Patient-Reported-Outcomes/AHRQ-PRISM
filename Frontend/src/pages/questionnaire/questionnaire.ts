import { Component, ChangeDetectorRef } from '@angular/core';
import { NavController, NavParams } from 'ionic-angular';
import { QuestionnaireProvider } from './../../providers/questionnaire/questionnaire';
import { AuthProvider } from './../../providers/auth/auth';

@Component({
  selector: 'page-questionnaire',
  templateUrl: 'questionnaire.html'
})
export class QuestionnairePage {
  questionnaire: any;
  currentItem: any;
  id: any;
  questionId: any;

  get questionnairePageAnswerSelectedHandler() {
    return this.answerSelected.bind(this);
  }

  constructor(
    public navCtrl: NavController,
    public navParams: NavParams,
    public questionnaireProvider: QuestionnaireProvider,
    public authProvider: AuthProvider,
    private _changeDetector: ChangeDetectorRef
  ) {
    this.id = navParams.data.id;
    this.questionId = navParams.data.questionId;
    this.questionnaireProvider.findQuestionnaireResponse(navParams.data.id).then((questResp) => {
      this.questionnaire = questResp;
      let question;

      if (questResp.contained[0].item) {
        question = questResp.contained[0].item.find(i => i.linkId === this.questionId);
      }

      if (question) {
        return this.updateQuestion(question);
      }

      this.questionnaireProvider.getNextItem(questResp.id).then(item => {
        this.updateQuestion(item);
      });
    });
  }

  ionViewCanEnter(): boolean | Promise<any>{
    return this.authProvider.isAuthenticated(this.navCtrl);
  }

  ionViewWillEnter() {
    if (this.currentItem) {
      this.clearSelection();
    }
  }

  answerSelected(answer) {
    this._changeDetector.detectChanges();
    this.questionnaireProvider.postNextItem(this.questionnaire.id, this.currentItem.linkId, answer).then(item => {
      if (Array.isArray(item) && item['length'] === 0) {
        setTimeout(() => {
          this.navCtrl.push('ResultsPage', { id: this.questionnaire.id })
        }, 0)
      } else {
        this.navCtrl.push('questionnaire-page', { id: this.id, questionId: item['linkId'] });
      }
    })
  }

  onBack() {
    this.navCtrl.pop();
  }

  onHelp() {
    this.navCtrl.push('HelpPage');
  }

  updateQuestion(item) {
    if (Array.isArray(item) && item['length'] === 0) {
      setTimeout(() => {
        this.navCtrl.push('ResultsPage', {id: this.questionnaire.id})
      }, 0)
    } else {
      this.currentItem = item;
      this._changeDetector.detectChanges();
    }
  }

  async clearSelection() {
    this.currentItem.item.forEach(item => {
      if (item.type !== 'choice') {
        return;
      }

      delete item.isAnswered;

      item.answerOption.forEach(answer => {
        delete answer.isSelected;
      });
    });
  }
}
