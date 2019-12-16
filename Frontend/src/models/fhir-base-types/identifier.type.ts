import { CodeableConcept } from './codeable-concept.type';
import { Period } from './period.type'

export interface Identifier {
  use: string;
  type: CodeableConcept;
  system: string;
  value: string;
  period: Period;
  // assigner: Reference<Organization>;
}
