import { Component, Input } from '@angular/core';
import { ChangeDetectorRef } from '@angular/core';

@Component({
  selector: 'choice-item-component',
  templateUrl: 'choice-item-component.html'
})
export class ChoiceItemComponent {
  @Input() item: any;
  @Input() choiceItemFunctionIn: Function;
  answerIndex: any;

  constructor(private ref: ChangeDetectorRef) {}

  answerClicked(val, index) {
    if (this.item['isAnswered']) {
      return;
    }

    val.isSelected = true;
    this.item['isAnswered'] = true;
    this.answerIndex = index;

    this.ref.markForCheck();
    this.ref.detectChanges();
    setTimeout(() => {
      this.choiceItemFunctionIn(val)
    }, 0);
  }
}
