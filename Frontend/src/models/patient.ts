import { Identifier } from './fhir-base-types/identifier.type';
import { HumanName } from './fhir-base-types/human-name.type';
import { ContactPoint } from './fhir-base-types/contact-point.type';

export interface Patient {
  resourceType: string;
  id: string;
  gender: string;
  birthDate: string;
  name: Array<HumanName>;
  telcom: Array<ContactPoint>;
  identifier: Array<Identifier>;
  [ key: string ]: any;
}
