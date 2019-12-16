import { ENV } from '@env'

import { Injectable } from '@angular/core';
import { API } from 'aws-amplify';

import { QuestionnaireResponse } from '../../models/questionnaire-response';
import { QuestionnaireItem } from '../../models/questionnaire';

import { ApiClient } from '../api-client';

@Injectable()
export class QuestionnaireProvider {
  API: any;
  questionnaireResponses: Array<QuestionnaireResponse>;
  hasRetrievedHistory: boolean;
  checkedInProgress: boolean;
  inProgressQuestionnaireResponse: QuestionnaireResponse | void;

  constructor(public apiClient: ApiClient) {
    this.hasRetrievedHistory = false;
    this.questionnaireResponses = [];

    this.inProgressQuestionnaireResponse = null;
    this.checkedInProgress = false;
  }

  public mostRecentQuestionnaire() {
    return this.questionnaireResponses[0]
  }

  public findInProgressQuestionnaire(): Promise<void | QuestionnaireResponse> {
    if (this.checkedInProgress) {
      return new Promise((r) => {
        r(this.inProgressQuestionnaireResponse)
      })
    }

    return this.getQuestionnaireResponses('in-progress').then((data) => {
      if (data && data.length > 0) {
        this.inProgressQuestionnaireResponse = data[0];
        this.checkedInProgress = true;
        return data[0];
      }
    });
  }

  // Find cached responses by id first and then query server if they don't exist
  public findQuestionnaireResponse(questionnaireResponseId, skip_cache = false): Promise<QuestionnaireResponse> {
    if (!skip_cache) {
      const foundQuestionnaire = this.questionnaireResponses.find((elem) => { return elem.id === questionnaireResponseId })
      if (foundQuestionnaire) { return new Promise((resolve, r) => { resolve(foundQuestionnaire) }); }
    }

    // Use the lambda server
    return API.get(
      'PrismAPI', `/QuestionnaireResponses/${questionnaireResponseId}`, {}
    ).then((data) => {
      this.findOrUpdateCache(data['questionnaireResponses']);
      return data['questionnaireResponses'];
    });

    // Use local server
    // return this.apiClient.get({url: `${ENV.apiLambda.baseUrl}/QuestionnaireResponses/${questionnaireResponseId}`}).then((data) => {
    //   this.findOrUpdateCache(data['questionnaireResponses']);
    //   return data['questionnaireResponses'];
    // }).catch((err) => {
    //   console.log('err', err);
    // });
  }

  // Get questionnaire reponses for the current user
  // The QuestionnaireResponses endpoint is auth protected
  // status can be 'in-progress' or 'completed'
  getQuestionnaireResponses(status) : Promise<any> {
    if (status === 'completed') {
      if (this.hasRetrievedHistory === true) {
        // If we've already gotten data then we're up to date. Just return the cache filtered to
        // only completed questionnaireResponses
        return new Promise((r) => r(this.questionnaireResponses.filter((item) => {
          return item.status === 'completed';
        })));
      }

      this.hasRetrievedHistory = true
    }

    // Use lambda
    return API.get('PrismAPI',
      '/QuestionnaireResponses',
      { queryStringParameters: { status: status } }
    ).then((data) => {
      this.findOrUpdateCache(data['questionnaireResponses'])

      return data['questionnaireResponses'].sort((x, y) => {
        return new Date(y.authored).getTime() - new Date(x.authored).getTime();
      });
    }).catch((error) => {
      // This logs a 401 unauthenticated error
      console.log(error)
    });

    // // Use Local
    // return this.apiClient.get({url: '${ENV.apiLambda.baseUrl}/QuestionnaireResponses', params: { status: status }}).then((data) => {
    //   this.findOrUpdateCache(data['questionnaireResponses'])

    //   return data['questionnaireResponses'].sort((x, y) => {
    //     return new Date(y.authored).getTime() - new Date(x.authored).getTime();
    //   });
    // }).catch((err) => {
    //   console.log('err', err);
    // });
  }

  postNextItem(questionnaireResponseId, linkId, answer) : Promise<void | QuestionnaireItem> {
    const data = {
      linkId: linkId,
      answer: [
        { value: answer.text }
      ]
    }

    // Run against local server
    // const options = {
    //   url: `${ENV.apiLambda.baseUrl}/QuestionnaireResponses/${questionnaireResponseId}/next-q`,
    //   params: { item: data },
    //   headers: {
    //     'Accept': 'application/json',
    //     'Content-Type': 'application/x-www-form-urlencoded'
    //   }
    // }

    // return this.apiClient.post(options).then((data) => {
    //   const item: QuestionnaireItem = data['questionnaireItem']

    //   console.log('item:', item)
    //   if (Array.isArray(item) && item.length === 0) {
    //     this.inProgressQuestionnaireResponse = null;
    //     return item
    //   }

    //   return this.findQuestionnaireResponse(questionnaireResponseId).then((resp) => {
    //     resp.contained[0].item.push(item)

    //     return item;
    //   });
    // }).catch((err) => {
    //   console.log('err', err);
    // });

    return API.post('PrismAPI',
      `/QuestionnaireResponses/${questionnaireResponseId}/next-q`, { body: { item: data } }
    ).then((data) => {
      const item: QuestionnaireItem = data['questionnaireItem']

      if (Array.isArray(item) && item.length === 0) {
        this.inProgressQuestionnaireResponse = null;
        return item
      }

      return this.findQuestionnaireResponse(questionnaireResponseId).then((resp) => {
        // If we don't have an item, push it into the contained
        if (!resp.contained[0].item){
          resp.contained[0].item = [item];
        } else if (!resp.contained[0].item.find(i => i.linkId === item.linkId)) {
          resp.contained[0].item.push(item);
        }

        return item;
      });
    }).catch((error) => {
      // This logs a 401 unauthenticated error
      console.log('Failed GET /QuestionnaireResponses. Something is not right')
      console.log(error)
    });
  }


  getNextItem(questionnaireResponseId) : Promise<void | QuestionnaireItem> {
    // return this.apiClient.get({url: `${ENV.apiLambda.baseUrl}/QuestionnaireResponses/${questionnaireResponseId}/next-q`}).then((data) => {
    //   const item: QuestionnaireItem = data['questionnaireItem']

    //   return this.findQuestionnaireResponse(questionnaireResponseId).then((resp) => {
    //     resp.contained[0].item.push(item)

    //     return item;
    //   });
    // }).catch((err) => {
    //   console.log('err', err);
    // });

    return API.get('PrismAPI',
      `/QuestionnaireResponses/${questionnaireResponseId}/next-q`,
      {}
    ).then((data) => {
      const item: QuestionnaireItem = data['questionnaireItem']

      if (Array.isArray(item) && item.length === 0) {
        this.inProgressQuestionnaireResponse = null;
        return item
      }

      return this.findQuestionnaireResponse(questionnaireResponseId).then((resp) => {
        if (!resp.contained[0].item){
          resp.contained[0].item = [item];
        } else if (!resp.contained[0].item.find(i => i.linkId === item.linkId)) {
          resp.contained[0].item.push(item);
        }

        return item;
      });
    }).catch((err) => {
      console.log('err', err);
    });
  }

  private findOrUpdateCache(data) {
    if (Array.isArray(data)) {
      data.forEach((item) => { this.findOrUpdateSingle(item) })
    } else {
      this.findOrUpdateSingle(data)
    }

    this.questionnaireResponses = this.questionnaireResponses.sort((x, y) => {
      return new Date(y.authored).getTime() - new Date(x.authored).getTime();
    })
  }

  private findOrUpdateSingle(qr) {
    const idx = this.questionnaireResponses.findIndex((elem) => {
      return elem.id === qr.id;
    })

    if (idx !== -1) {
      this.questionnaireResponses[idx] = qr
    } else {
      this.questionnaireResponses.push(qr)
    }
  }
}
