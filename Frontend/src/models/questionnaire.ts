import { Identifier } from './fhir-base-types/identifier.type';
import { Coding } from './fhir-base-types/coding.type'

export interface AnswerOption {
  id?: string;
  text: string;
  displayOrder: number;
}

export interface QuestionnaireItem {
  id?: string;
  linkId: string;
  prefix?: string;
  text?: string;
  type: string;
  displayOrder?: number;
  code?: Array<Coding>;
  answerOption?: Array<AnswerOption>;
  item?: Array<QuestionnaireItem>;
}

export interface Questionnaire {
  resourceType: string;
  id: string;
  title?: string;
  description?: string;

  identifier?: Identifier;
  item: Array<QuestionnaireItem>
}
