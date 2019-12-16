require_relative './pop_data'

module Population
  COL_TOTAL = 0
  COL_GENDERS = {
    female: 1,
    male: 2
  }

  COL_AGES = {
    lt_35: 3,
    lt_45: 4,
    lt_55: 5,
    lt_65: 6,
    lt_75: 7,
    gte_75: 8
  }

  def self.get_percentiles(form_id:, t_score:, gender: nil, age: nil)
    form_data = @data.select { |k, v| k.downcase == form_id.downcase }
                     .first&.dig(1)
    return nil if form_data.nil?

    percentiles = form_data[t_score.to_i]
    return nil if percentiles.nil?

    gender_col = COL_GENDERS[gender&.to_sym]
    if gender_col
      gender_res = {
        description: gender.to_s,
        value: percentiles[gender_col]
      }
    else
      gender_res = nil
    end

    if age
      age_desc, age_col = if age < 35
                            ['age < 35', COL_AGES[:lt_35]]
                          elsif age < 45
                            ['35 <= age < 45', COL_AGES[:lt_45]]
                          elsif age < 55
                            ['45 <= age < 55', COL_AGES[:lt_55]]
                          elsif age < 65
                            ['55 <= age < 65', COL_AGES[:lt_65]]
                          elsif age < 75
                            ['65 <= age < 75', COL_AGES[:lt_75]]
                          else
                            ['age >= 75', COL_AGES[:gte_75]]
                          end

      age_res = {
        description: age_desc,
        value: percentiles[age_col]
      }
    else
      age_res = nil
    end

    {
      age: age_res,
      gender: gender_res,
      total: percentiles[COL_TOTAL]
    }
  end
end
