import { Component, Input } from '@angular/core';

@Component({
  selector: 'group-component',
  templateUrl: 'group-component.html'
})
export class GroupComponent {
  @Input() groupComponentSendAnswer: Function;
  @Input() item: any;

  constructor() { }

  get groupComponentSendAnswerFunc() {
    return this.groupComponentSendAnswer.bind(this);
  }
}
