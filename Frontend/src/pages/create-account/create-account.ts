import { Component } from '@angular/core';
import { NavController, NavParams } from 'ionic-angular';
import { FormGroup, FormControl, Validators } from '@angular/forms';
import { CustomValidators } from 'ng2-validation';

@Component({
  selector: 'page-create-account',
  templateUrl: 'create-account.html',
})
export class CreateAccountPage {
  private form: FormGroup;
  public birthday: any;


  constructor(
    public navCtrl: NavController,
    public navParams: NavParams)
    {
      this.prepareForm();
      this.birthday = this.navParams.get('birthday');
    }

  ionViewDidLoad() {
    console.log('ionViewDidLoad CreateAccountPage');
  }

  /**
   * Prepare the registration form.
   */
  private prepareForm(): void {
    this.form = new FormGroup({
      email: new FormControl('', Validators.compose([Validators.required, Validators.email])),
      password: new FormControl('', Validators.compose([Validators.required, Validators.minLength(6)])),
      confirmPassword: new FormControl //Need to add validation message when passwords don't match
    });

    const passwordControl = this.form.controls.password;
    this.form.controls.confirmPassword
      .setValidators([CustomValidators.equalTo(passwordControl)]);
    this.form.controls.confirmPassword.updateValueAndValidity();
  }

  /**
   * Submit registration. If successful, proceed into app.
   */
  // private register() {
  //   const user = {
  //     birthday: this.birthday,
  //     email: this.form.value.email,
  //     dateJoined: new Date()
  //   };
  //   const password = this.form.value.password;

  //   console.log('user: ', user, 'password: ', password);
  // }

  goToLogin() {
    console.log('Log In!');
  }

}
