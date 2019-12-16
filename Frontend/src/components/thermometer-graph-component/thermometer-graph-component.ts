import { Component, Input } from '@angular/core';

@Component({
  selector: 'thermometer-graph-component',
  templateUrl: 'thermometer-graph-component.html'
})
export class ThermometerGraphComponent {
  @Input() score: number;
  @Input() color: string;

  constructor () {
    console.log('color: ', this.color);
  }

  pointerStyles() {
    let percentage;

    if  (this.score < 15) {
      percentage = 0;
    } else if (this.score > 85) {
      percentage = 100;
    } else {
      percentage = ((this.score - 15) / 70) * 100;
    }

    return {
      'left': `${percentage}%`
    };
  }

  scoreStyles() {
    return this.color === 'pink' ? { color: 'black' } : { };
  }

  imageSrc() {
    const fileName = this.color === 'pink' ? 'scale-arrow-pink.png' : 'scale-arrow.png';

    return `../../assets/imgs/${fileName}`;
  }
}
