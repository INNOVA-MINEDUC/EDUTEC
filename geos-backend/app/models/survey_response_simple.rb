class SurveyResponseSimple
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Memoist

  store_in collection: "survey_responses"

  MAX_NUMBER_OF_RETRIES = 5
  RESET_NUMBER_OF_RETRIES = 1
  RETRY_PERIOD = 5.minutes

  field :vision_level, type: :integer
  field :competence_level, type: :integer
  field :resource_level, type: :integer
  field :infrastructure_level, type: :integer
  field :status, type: String
  field :submitted_at, type: DateTime
  field :number_of_tries_left, type: Integer, default: MAX_NUMBER_OF_RETRIES
  field :number_of_tries, type: Integer, default: 0
  field :in_use, type: Mongoid::Boolean, default: false
  field :results, type: Array
  field :guests, type: Array
  field :type, type: String
  field :survey_id, type: BSON::ObjectId
  field :user_id, type: BSON::ObjectId
  field :survey_schedule_id, type: BSON::ObjectId
  field :school_id, type: BSON::ObjectId
end