import { Period } from './period.type'

export interface HumanName {
  use: string;
  text: string;
  family: string;
  given: Array<string>;
  prefix: Array<string>;
  suffix: Array<string>;
  period: Period;
}
