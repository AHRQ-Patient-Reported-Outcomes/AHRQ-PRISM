require 'spec_helper'

describe Population do
  describe 'get_percentiles' do
    it 'returns percentiles' do
      res = Population.get_percentiles(
        form_id: 'd2fa612d-c290-4b88-957d-1c27f48ee58c',
        t_score: 43,
        gender: :male,
        age: 40
      )

      expect(res).to eq(
        age: {
          description: '35 <= age < 45',
          value: 21
        },
        gender: {
          description: 'male',
          value: 27
        },
        total: 26
      )
    end

    it 'returns percentiles with float t_scores' do
      res = Population.get_percentiles(
        form_id: '96fe494D-F176-4EFB-A473-2AB406610626',
        t_score: 84.0
      )

      expect(res).to eq(
        age: nil,
        gender: nil,
        total: 99
      )
    end

    it 'returns nil for a bad form ID' do
      res = Population.get_percentiles(
        form_id: 'fake-form-id',
        t_score: 43,
        gender: :male,
        age: 40
      )

      expect(res).to be_nil
    end

    it 'returns nil for a bad t-score' do
      res = Population.get_percentiles(
        form_id: 'd2fa612d-c290-4b88-957d-1c27f48ee58c',
        t_score: 9000,
        gender: :male,
        age: 40
      )

      expect(res).to be_nil
    end

    it 'nils out for missing gender' do
      res = Population.get_percentiles(
        form_id: 'd2fa612d-c290-4b88-957d-1c27f48ee58c',
        t_score: 43,
        gender: nil,
        age: 40
      )

      expect(res).to eq(
        age: {
          description: '35 <= age < 45',
          value: 21
        },
        gender: nil,
        total: 26
      )
    end

    it 'nils out for missing age' do
      res = Population.get_percentiles(
        form_id: 'd2fa612d-c290-4b88-957d-1c27f48ee58c',
        t_score: 43,
        gender: :male
      )

      expect(res).to eq(
        age: nil,
        gender: {
          description: 'male',
          value: 27
        },
        total: 26
      )
    end
  end
end
