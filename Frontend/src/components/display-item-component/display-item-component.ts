import { Component, Input } from '@angular/core';

@Component({
  selector: 'display-item-component',
  templateUrl: 'display-item-component.html'
})
export class DisplayItemComponent {
  @Input() item: any;

  constructor() { }

}
