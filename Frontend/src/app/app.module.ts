import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { ErrorHandler, NgModule } from '@angular/core';
import { IonicApp, IonicErrorHandler, IonicModule } from 'ionic-angular';
import { SplashScreen } from '@ionic-native/splash-screen';
import { StatusBar } from '@ionic-native/status-bar';
import { NgxMaskIonicModule } from 'ngx-mask-ionic'

import { MyApp } from './app.component';
import { SettingsPage } from './../pages/settings/settings';
import { ResultsPage } from '../pages/results/results';
import { CreateAccountPage } from './../pages/create-account/create-account';
import { CreateAccountBirthdayPage } from './../pages/create-account-birthday/create-account-birthday';
import { WelcomePage } from './../pages/welcome/welcome';
import { DownloadPage } from '../pages/download/download';
import { ResultsModalPage } from './../pages/results-modal/results-modal';

import { MePage } from '../pages/me/me';
import { AuthPage } from '../pages/auth/auth';
import { PrequestionnairePage } from '../pages/prequestionnaire/prequestionnaire';
import { QuestionnairePage } from '../pages/questionnaire/questionnaire';
import { HistoryPage } from '../pages/history/history';
import { ArticlesPage } from './../pages/articles/articles';
import { HelpPage } from '../pages/help/help';

// Providers
import { AuthProvider } from '../providers/auth/auth';
import { QuestionnaireProvider } from '../providers/questionnaire/questionnaire';
import { ApiClient } from '../providers/api-client';
import { PatientProvider } from '../providers/patient';
import { AwsProvider } from '../providers/aws/aws';

import { ComponentsModule } from '../components/components.module';
import { HistoryProvider } from '../providers/history/history';
import { InAppBrowser } from '@ionic-native/in-app-browser/ngx';

// Auto Logout Service
import { AutoLogout } from '../auto-logout';

@NgModule({
  // declarations are to make directives (including components and pipes) from the current
  // module available to other directives in the current module. Selectors of directives,
  // components or pipes are only matched against the HTML if they are declared or imported.
  declarations: [
    MyApp,
    SettingsPage,
    ResultsPage,
    CreateAccountBirthdayPage,
    CreateAccountPage,
    WelcomePage,
    DownloadPage,
    ResultsModalPage,

    MePage,
    PrequestionnairePage,
    AuthPage,
    QuestionnairePage,
    HistoryPage,
    ArticlesPage,
    HelpPage,
  ],
  // imports makes the exported declarations of other modules available in the current module
  imports: [
    BrowserModule,
    HttpClientModule,
    NgxMaskIonicModule.forRoot(),
    IonicModule.forRoot(MyApp, {}, {
      links: [
        { component: MePage, name: 'MePage', segment: 'me' },
        { component: AuthPage, name: 'AuthPage', segment: 'auth' },
        { component: WelcomePage, name: 'WelcomePage', segment: 'welcome' },
        { component: PrequestionnairePage, name: 'prequestionnaire-page', segment: 'prequestionnaire/:id' },
        { component: QuestionnairePage, name: 'questionnaire-page', segment: 'questionnaire/:id' },
        { component: HistoryPage, name: 'HistoryPage', segment: 'history' },
        { component: ResultsPage, name: 'ResultsPage', segment: 'results/:id' },
        { component: ArticlesPage, name: 'ArticlesPage', segment: 'articles' },
        { component: DownloadPage, name: 'DownloadPage', segment: 'download' },
        { component: HelpPage, name: 'HelpPage', segment: 'help' },
      ]
    }),
    ComponentsModule
  ],
  bootstrap: [IonicApp],
  // entryComponents registers components for offline compilation so that they can
  // be used with ViewContainerRef.createComponent().
  // Components used in router configurations are added implicitly.
  entryComponents: [
    MyApp,
    SettingsPage,
    ResultsPage,
    CreateAccountBirthdayPage,
    CreateAccountPage,
    WelcomePage,
    DownloadPage,
    ResultsModalPage,

    MePage,
    PrequestionnairePage,
    AuthPage,
    QuestionnairePage,
    HistoryPage,
    ArticlesPage,
    HelpPage,
  ],
  // providers are to make services and values known to DI. They are added to the root
  // scope and they are injected to other services or directives that have them as dependency.
  providers: [
    StatusBar,
    SplashScreen,
    {provide: ErrorHandler, useClass: IonicErrorHandler},
    AuthProvider,
    QuestionnaireProvider,
    HistoryProvider,
    ApiClient,
    AwsProvider,
    PatientProvider,
    InAppBrowser,
    AutoLogout
  ]
})
export class AppModule {}
