import { Period } from './period.type'

export interface ContactPoint {
  system: string;
  value: string;
  use: string;
  rank: number;
  period: Period;
}
