module Api
  module V1
    class TranslationsController < ApiController
      before_action :authenticate_user!, only: [:save_translation]
      
        #Read the JSON tranlation file located at app/assets/translations and respond it
        def get_translation_by_lang
        
        params.permit(:lang, :dictionary, :format)
        lang = params[:lang]
        dictionary = params[:dictionary] || 'legacy'

        file_path = "app/assets/lang-dictionaries/#{dictionary}/#{lang}.json"

        if File.exist?(file_path)
          file = File.read(file_path)
          render json: {status: 'SUCCESS', message: 'Translation found', data: JSON.parse("[#{file}]")}, status: :ok
        else
          render json: {status: 'ERROR', message: 'Translation file not found', data: []}, status: :not_found
        end
      end

      # Insert a new language or edit an existing language
      # @param: access_token (user admin) and lang
      # @return [JSON]: status, message and data (with all attributes translated)
      def save_translation
        user = current_user
        if user.admin?
          translation = Translation.where(lang: params[:translation][:lang]).first
          if (translation.nil?) # Insert
            translation = Translation.new(translations_params)
            if translation.save
              render json: {status: 'SUCCESS', message:'Saved translation', data:translation},status: :ok
            else
              render json: {status: 'ERROR', message:'Translation not saved', data:nil},status: :unprocessable_entity
            end
          else # Update
            if translation.update_attributes(translations_params)
              render json: {status: 'SUCCESS', message:'Updated translate', data:params.require(:translation)},status: :ok
            else
              render json: {status: 'ERROR', message:'Translate not update', data:nil},status: :unprocessable_entity
            end
          end
        end
      end
      
      def update_translation_by_lang
        user = current_user
        if user&.admin?

          params.permit(:access_token, :lang, :format, :translatiom, :data)

          dasData = JSON.parse(params[:data])
          targetLang = dasData[:lang]

          #remove conflicting fields from data
          dasData.delete(:_id)
          dasData.delete(:created_at)
          dasData.delete(:updated_at)

          #Delete the old translation by language
          Translation.where(lang: targetLang).destroy_all

          ##Insert the new Data Translation
          #trans = Translation.new(dasData)

          if trans.save(validate: false)
            render json: {status: 'SUCCESS', message:'Updated translate', data:trans},status: :ok
          else
            render json: {status: 'ERROR', message:'Translate not update', data:nil},status: :unprocessable_entity
          end
        else
          render json: {status: 'ERROR', message:'User not admin', data:nil},status: :unauthorized
        end
      end
      
      private
      def translations_params
        params.require(:translation).permit(translation: params[:translation].keys)
      end    
    end
  end
end