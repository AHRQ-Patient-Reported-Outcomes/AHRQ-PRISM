import { Component, Input } from '@angular/core';
import { QuestionnaireProvider } from '../../providers/questionnaire/questionnaire';

@Component({
  selector: 'parent-list-component',
  templateUrl: 'parent-list-component.html'
})
export class ParentListComponent {
  @Input() parentListComponentSendAnswer: Function;
  @Input() questionnaireId: string;
  @Input() item: any;

  constructor(public questionProvider: QuestionnaireProvider)
  { }

  // ngOnInit(){
  //   console.log('ngOnInit')
  // }

  // ngOnChanges(){
  //   console.log('ngOnChanges')
  // }

  // ngDoCheck(){
  //   console.log('ngDoCheck')
  // }

  // ngAfterContentInit(){
  //   console.log('ngAfterContentInit')
  // }

  get parentComponentSendAnswerFunc() {
    return this.parentListComponentSendAnswer.bind(this);
  }
}
