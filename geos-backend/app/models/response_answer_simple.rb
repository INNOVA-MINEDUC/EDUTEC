class ResponseAnswerSimple
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'response_answeres'

  field :school_id, type: BSON::ObjectId
  field :user_id, type: BSON::ObjectId
  field :survey_response_id, type: BSON::ObjectId
  field :options, type: Array
  field :other_text, type: String
  field :survey_question_id, type: BSON::ObjectId

end