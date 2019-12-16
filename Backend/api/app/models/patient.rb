require_relative 'model_base'

module Models
  class Patient
    include ModelBase

    # Attributes
    # ============================================
    alias_method :id, :primary_key

    string_attr :organization_id, database_attribute_name: 'GSI_1_PK'
    string_attr :gsi_1_sk, database_attribute_name: 'GSI_1_SK'

    # Validations
    # ============================================
    validates_presence_of :given_name, :family_name, :birthDate,
                          :organization_id, :gender

    validate :gsi_1_sk_is_id
    validate :gender_is_valid

    before_validation :set_gsi_1_sk

    string_attr :id, database_attribute_name: 'patientId'
    map_attr :meta
    list_attr :identifier
    list_attr :name
    list_attr :telecom
    string_attr :gender
    date_attr :birthDate
    list_attr :address
    list_attr :contact
    list_attr :communication

    map_attr :_fhir_access_data
    def fhir_access_data
      FhirAccessData.new(_fhir_access_data || {})
    end

    def resourceType
      'Patient'
    end

    def attributes
      {
        resourceType: resourceType,
        address: address,
        birthDate: birthDate,
        communication: communication,
        contact: contact,
        gender: gender,
        identifier: identifier,
        id: id,
        name: name
      }
    end

    # Main Body
    # ============================================
    class << self
      alias :dynamoDB_find :find

      def find(id)
        dynamoDB_find(primary_key: id, sort_key: 'patient')
      end
    end

    # Returns AWS::Record::ItemCollection populated with QuestionnaireResponses
    def questionnaire_responses
      QuestionnaireResponse.for_patient(primaryKey).to_a
    end

    def score_histories
      ScoreHistory.for_patient(primaryKey).to_a
    end

    private

    def set_gsi_1_sk
      self.gsi_1_sk = 'patient'
      self.sort_key = 'patient'
    end

    def gsi_1_sk_is_id
      return if gsi_1_sk == 'patient'

      errors.add(:gsi_1_sk, 'must equal "patient"')
    end

    def gender_is_valid
      return if %w[male female other unknown].include? gender

      errors.add(:gender, 'is not valid code. Valid codes are: male, female, other, unknown')
    end

    def given_name
      return nil if name.nil? || name.empty?
      name.first.with_indifferent_access[:given]
    end

    def family_name
      return if name.nil? || name.empty?
      name.first.with_indifferent_access[:family]
    end

    # ========================================================================
    # FhirAccessData
    # ========================================================================
    class FhirAccessData
      include ModelBase

      # Do not want to persist
      def self.save; end

      string_attr :access_token
      string_attr :refresh_token
      string_attr :id_token
      integer_attr :expires_in
    end
  end
end
