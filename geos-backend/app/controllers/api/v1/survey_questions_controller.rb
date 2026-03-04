module Api
  module V1
    class SurveyQuestionsController < ApiController

		def get_all 
			user = current_user
			section_id = params[:idSection]

			@questions =  SurveyQuestion.where(:survey_section_id => section_id).order(:question_order => 1)
		
			puts "-------@questions----------"
			puts section_id
			puts @questions
			puts "-----------------"

			if @questions.empty?
			  render json: []
			else
			  render json: @questions.to_json
			end
		end

		def get_section
			user = current_user
			if user.admin?
				# Find the SurveySection by _id
				@section = SurveySection.find(params[:id])
            
				# Render the section as JSON
				render json: @section.to_json
			end
		end

		def update_section
			user = current_user
			if user.admin?
				@section = SurveySection.find(params[:id])
				
				#Adjust locale to save
				I18n.locale =  (!params[:lang].nil?) ? params[:lang] :  I18n.default_locale
				params.permit(:id, :lang, :name, :description)
				if @section.update_attributes(name: params[:name],description: params[:description])
					render json: @section.to_json
				else
					Rails.logger.info(@section.errors.messages.inspect)
					render json: {status: 'ERROR', message:'Can not perform this action', data: nil},status: :unprocessable_entity
				end
			else
				render json: {status: 'ERROR', message:'Only the admin can perform this action', data: nil},status: :unauthorized
			end
		end      

		def update_section_partial
			user = current_user
			if user.admin?
				@section = SurveySection.find(params[:id])
          
				# Permit the parameters from the request body
				permitted_params = params.permit(
					:access_token, :lang, :format, :id, :survey_question,
					:position,
					user_type: []
				)
				
				# Update the SurveySection with the permitted parameters
				if @section.update_attributes(position: params[:position], user_type: params[:user_type])
					render json: @section.to_json
				else
					render json: {status: 'ERROR', message: 'Can not perform this action', data: @section.errors.full_messages}, status: :unprocessable_entity
				end
			end
		end

		def create_section
		user = current_user
		if user.admin?
			survey_question_params = (params[:survey_question])
			permitted_params = survey_question_params.permit(
				:position,
				:survey_id,
				:has_feedback,
				:has_result,
				:has_question,
				:name,
				user_type: [],
			)
			@section = SurveySection.new(permitted_params)
			
			if @section.save
				render json: @section.to_json
			else
				render json: {status: 'ERROR', message: 'Can not perform this action', data: @section.errors.full_messages}, status: :unprocessable_entity
			end
		end
		end

		def delete_section
		user = current_user
		if user.admin?
			# Find the SurveySection by _id
			@section = SurveySection.find(params[:id])
			
			# Delete the SurveySection
			if @section.destroy
				render json: {status: 'SUCCESS', message: 'SurveySection deleted successfully', data: @section}, status: :ok
			else
				render json: {status: 'ERROR', message: 'Failed to delete SurveySection', data: @section.errors.full_messages}, status: :unprocessable_entity
			end
		end
		end

		def create_question
		user = current_user
		if user.admin?

			puts "-------params----------"
			puts params[:survey_question]
			puts "-----------------"

			survey_question_params = (params[:survey_question])
			permitted_params = survey_question_params.permit(
				:type,
				:survey_id,
				:survey_section_id,
				:page,
				:weight,
				:compound,
				:compound_ref,
				:name,
				:question_order,
				survey_question_description: [
					:id,
					:weight,
					:value
				]
			)

			puts "-------permitted_params----------"
			puts permitted_params[:survey_question_description]
			puts "-----------------"

			@question = SurveyQuestion.new(permitted_params.except(:survey_question, :access_token, :lang, :format))

			# render json: @question.to_json
			if @question.save
				render json: @question.to_json
			else
				render json: {status: 'ERROR', message: 'Can not perform this action', data: @question.errors.full_messages}, status: :unprocessable_entity
			end
		end
		end

		def update_question
		user = current_user
		if user.admin?
			@question = SurveyQuestion.find(params[:id])
			
			#Adjust locale to save
			I18n.locale =  (!params[:lang].nil?) ? params[:lang] :  I18n.default_locale
			params.permit(:id, :lang, :survey_question_description, :name, :question_order, :obs)
			# build 'survey_question_description field'
			questionDescription = Array.new
			idx = 0
			params[:survey_question_description].each do |qd|
			questionDescription[idx] = {}
			questionDescription[idx]["id"] = qd["id"]
			questionDescription[idx]["value"] = qd["value"]
			questionDescription[idx]["weight"] = qd["weight"]
			idx += 1            
			end

			if @question.update_attributes(
											name: params[:name],
											question_order: params[:question_order],
											obs: params[:obs],
											survey_question_description: questionDescription
											)
			render json: @question.to_json
			else
			# print the errors to the development log
			Rails.logger.info(@question.errors.messages.inspect)
			render json: {status: 'ERROR', message:'Can not perform this action', data: nil},status: :unprocessable_entity
			end
		else
			render json: {status: 'ERROR', message:'Only the admin can perform this action', data: nil},status: :unauthorized
		end
		end

		def questions_list
		
			@lang = params[:lang]
					
			school = current_user.school
			survey_id = params[:id]
			@survey = Survey.find_by(:id => survey_id)

			@sections = SurveySection.where(:survey_id => survey_id).order(:position => 1)

			if !school.nil?
				type_role = school.type
				@questions = SurveyQuestion.any_of({:type_role.in => [type_role], :survey_id => survey_id}, {:type_role.in => ["",nil], :survey_id => survey_id}).order(:page => 1, :name => 1, :_id => 1)
			else
				@questions = SurveyQuestion.where({:survey_id => survey_id}).order(:page => 1, :name => 1, :_id => 1)
			end

			if @survey.shuffle_options
				shuffled_questions = Array.new
				@questions.each do |question|
				question.survey_question_description = question.survey_question_description.shuffle
				shuffled_questions.push(question) 
				end
				@questions = Array.new(shuffled_questions)
			end

			respond_to do |format|
				format.json
			end
		end

		def questions_with_answers
		school = current_user.school

		@questions = nil
		#default
		#:admin_state, :admin_city, :monitor_state, :monitor_city, :monitor_state_regional, :monitor_city_regional,
		if(current_user.admin_state? || current_user.monitor_state?  || current_user.monitor_state_regional?)
			type_role = "Estadual"
			@questions = SurveyQuestion.any_of({:type_role.in => [type_role], :state => current_user.state.id.to_s}, {:type_role.in => ["",nil]}).order(:page => 1, :name => 1)
		else
			type_role = "Municipal"
			@questions = SurveyQuestion.any_of({:type_role.in => [type_role], :city => current_user.city.id.to_s}, {:type_role.in => ["",nil]}).order(:page => 1, :names => 1)
		end

		render json: @questions.as_json
		@questions = nil
		end

		def index_manager
		state = nil
		city  = nil
		type_role = nil

		user = current_user
		if user.admin_state? || user.admin_city?
			affiliation_id = user.affiliation_id
		end

		idSection = SurveySection.where(:name => 'Perguntas Extra').first.id
		resp = SurveyQuestion.where(:affiliation_id => affiliation_id, :survey_section => idSection)

		ret_json = resp.to_json
		ret = JSON.parse(ret_json)
		ret.each do |element|

			new_desc = []
			count =0
			element['survey_question_description'].each do |desc|
			new_desc[count] = desc['value']
			count = count + 1
			end

			element['survey_question_description'] = new_desc
		end

		respond_to do |format|
			format.json {
			render :json => ret.to_json, :status => 200
			}
		end
		end

		def save_multiple
		success = false

		begin
			state = nil
			city  = nil
			type_role = nil

			user = current_user
			if user.admin_state? || user.admin_city?
			affiliation_id = user.affiliation_id
			end

			# delete old rows
			idSection = SurveySection.where(:name => 'Perguntas Extra').first.id
			SurveyQuestion.where(:affiliation_id => affiliation_id, :survey_section => idSection).destroy_all

			jsonNoTreated = JSON.parse(params[:survey_question])

			if jsonNoTreated
			obj = nil
			keyControl = nil
			options = nil
			len = jsonNoTreated.length

			count = 0
			jsonNoTreated.each do |k, v|
				if keyControl != k[1]
				#save last object
				if obj
					obj.save!
				end

				keyControl = k[1]
				obj = SurveyQuestion.new
				options = Array.new
				end

				if k.include? "type"
				obj.type = v
				elsif k.include? "name"
				obj.name = v
				else
				chave = k.split('-')[1]
				options[chave.to_i] = {id:9000 + Random.rand(100000000), value: v}
				end
				obj.survey_question_description = options
				obj.state = state
				obj.city = city
				obj.page = 7
				obj.type_role = type_role
				obj.survey_section = idSection

				count = count + 1

				if count >= len
				obj.save!
				end

			end
			obj.save!
			end

			render json: { :valid => true }.to_json
		rescue Exception => e
			Rails.logger.error e.backtrace.join("\n")

			render json: { :valid => false}.to_json
		end
		end

		private

		# Never trust parameters from the scary internet, only allow the white list through.
		def survey_question_params
		params.require(:survey_question).permit(:id,:name,:question_order,:position,:type,:survey_question_description,:state,:city,:type_role,:page,:weight,:obs,:only_principal,:has_child,:compound,:compound_ref,:compound_first,:not_normalize)
		end
    end
  end
end