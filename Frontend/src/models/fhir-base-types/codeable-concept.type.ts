import { Coding } from './coding.type'

export interface CodeableConcept {
  text: string;
  coding: Array<Coding>;
}
