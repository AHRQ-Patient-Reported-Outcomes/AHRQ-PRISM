import { CreateAccountPage } from './../create-account/create-account';
import { Component } from '@angular/core';
import { NavController, NavParams } from 'ionic-angular';
import { FormGroup, FormBuilder } from '@angular/forms';

@Component({
  selector: 'page-create-account-birthday',
  templateUrl: 'create-account-birthday.html',
})
export class CreateAccountBirthdayPage {
  private form: FormGroup;

  constructor(
    public navCtrl: NavController, 
    public navParams: NavParams,
    private formBuilder: FormBuilder) 
    {
      this.form = this.formBuilder.group({
        birthday: [''],
      });
    }

  ionViewDidLoad() {
    console.log('ionViewDidLoad CreateAccountBirthdayPage');
  }

  verifyBirthday() {
    const birthday = this.form.value.birthday;

    this.navCtrl.push(CreateAccountPage, {birthday: birthday});
  }

  goToLogin() {
    console.log('Log In!');
  }

}
