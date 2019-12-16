import { Injectable } from '@angular/core';
import { QuestionnaireProvider } from '../questionnaire/questionnaire';

@Injectable()
export class HistoryProvider {
  constructor(public questionnaireProvider: QuestionnaireProvider) {

  }

  // This gets a list of the questionnaire responses that a user has completed
  getHistory() : Promise<any> {
    return this.questionnaireProvider.getQuestionnaireResponses('completed').then((responses) => {
      return responses;
    });
  }

  getGraphScores() : Promise<any> {
    return this.getHistory().then((responses) => {
      return responses.map((resp) => {
        return {
          score: ((resp.theta * 10) + 50),
          date: new Date(resp.authored)
        }
      })
    })
  }

  getGraphScoresV2() : Promise<any> {
    return this.getHistory().then((responses) => {
      const data = responses.reduce((accumulator, currentValue) => {
        accumulator.xAxis.push((currentValue.theta * 10) + 50)
        accumulator.yAxis.push(new Date(currentValue.authored))

        return accumulator
      }, {xAxis: [], yAxis: []});

      return data;
    })
  }
}
