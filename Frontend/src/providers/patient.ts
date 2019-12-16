import { Injectable } from '@angular/core';
import { API } from 'aws-amplify';

import { ApiClient } from './api-client';
import { Patient } from '../models/patient';

@Injectable()
export class PatientProvider {
  currentPatient: Patient | void;
  checkedPatient: boolean;

  constructor(public apiClient: ApiClient) {
    this.currentPatient = null;
    this.checkedPatient = false;
  }

  public getCurrentPatient(): Promise<void | Patient> {
    if (this.checkedPatient) {
      return new Promise((r) => { r(this.currentPatient) })
    }

    // return this.apiClient.get({url: 'http://localhost:3030/Patients/current'})
    return API.get('PrismAPI', '/Patients/current',{}).then((data) => {
      this.currentPatient = data['patient'];
      this.checkedPatient = true
      return data['patient']
    })
  }
}
