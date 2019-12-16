import { Identifier } from './fhir-base-types/identifier.type';
import { Coding } from './fhir-base-types/coding.type'

import { Questionnaire } from './questionnaire'

interface PopulationComparison {
  age?: { description: string, value: number }
  gender?: { description: string, value: number }
  total: number
}

export interface Answer {
  value: string;
}

export interface QuestionnaireResponseItem {
  linkId: string;
  text?: string;
  code?: Array<Coding>;
  answer: Array<Answer>;
}

export interface QuestionnaireResponse {
  resourceType: string;
  id: string;
  status: string;
  authored: string; // the date authored on
  identifier?: Identifier;
  contained?: Array<Questionnaire>
  item?: Array<QuestionnaireResponseItem>;
  population_comparison?: PopulationComparison
  result_modal_data: any;
  theta: number; // this is used to calculate the score
  title: string; // this is the "title" of the survey to use on the Results page
}

export function populationComparison(qr: QuestionnaireResponse) {
  if (!qr.population_comparison) {
    return { allPeople: null, yourGender: null, yourAge: null }
  }

  const pop_comp = qr.population_comparison

  return {
    allPeople: pop_comp.total,
    yourGender: pop_comp.gender ? pop_comp.gender.value : null,
    yourAge: pop_comp.age ? pop_comp.age.value : null
  }
}
