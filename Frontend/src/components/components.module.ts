import { NgModule } from '@angular/core';
import { IonicModule } from 'ionic-angular';

import { ParentListComponent } from './parent-list-component/parent-list-component';
import { GroupComponent } from './group-component/group-component';
import { ChoiceItemComponent } from './choice-item-component/choice-item-component';
import { DisplayItemComponent } from './display-item-component/display-item-component';

import { LineGraphComponent } from './line-graph-component/line-graph-component';
import { ThermometerGraphComponent } from './thermometer-graph-component/thermometer-graph-component';

@NgModule({
  declarations: [
    ParentListComponent,
    GroupComponent,
    ChoiceItemComponent,
    DisplayItemComponent,
    LineGraphComponent,
    ThermometerGraphComponent
  ],
  imports: [IonicModule],
  exports: [
    ParentListComponent,
    GroupComponent,
    ChoiceItemComponent,
    DisplayItemComponent,
    LineGraphComponent,
    ThermometerGraphComponent
  ]
})

export class ComponentsModule {}
