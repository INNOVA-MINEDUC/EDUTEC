module Api
    module V1
        class ReportFollowUpController < ApiController

            require 'spreadsheet'

            respond_to :json, :pdf, :xls

            def xls

                dateFormat = "%F %T"

                #Init Spreadsheet
                book = Spreadsheet::Workbook.new
                sheetPrincipals = book.create_worksheet name: 'Registro directores por centro'
                sheetPrincipalsThatAnswered = book.create_worksheet name: 'Cantidad de respuestas Dir_centr'
                sheetTeachers = book.create_worksheet name: 'Registro docentes por centro'
                sheetTeachersThatAnswered = book.create_worksheet name: 'Cantidad de respuestas Doc_centr'
                sheetSchools = book.create_worksheet name: 'Listado de centros escolares'

                #Performance: schools buffer since it is used several times
                allSchools = self.fetchSchools

                #Base header
                baseHeaders = {
                    'Región' => 20,
                    'Departamento' => 20,
                    'Municipio' => 32,
                    'Codigo Centro' => 12,
                    'Centro Escolar' => 65,
                }

                # - Schools sheet
                #"
                schoolsSetter = -> (s) { [
                    s.province_name, #region
                    s.state_name, #depto
                    s.city_name, #municipio
                    s.inep_code, #codigo
                    s.name, #name
                ] }
                self.xlsFillSheet(
                    sheetSchools,
                    baseHeaders,
                    allSchools,
                    schoolsSetter
                )
                #"

                # - Principals sheet
                #"
                principalsSetter = -> (s) { 
                    #Can be NULL
                    resp = SurveyResponse.find_by(
                        :user_id => s._id
                    )
                    [
                        s.school.province_name, #region
                        s.school.state_name, #depto
                        s.school.city_name, #municipio
                        s.school.inep_code, #codigo
                        s.school.name,
                        s.name,
                        s.email,
                        resp&.submitted_at&.strftime(dateFormat),
                        resp&.status,
                    ]
                }
                self.xlsFillSheet(
                    sheetPrincipals,
                    baseHeaders.merge({
                        'Nombre director' => 45,
                        'E-mail' => 45,
                        'Fecha digitación de encuesta' => 25,
                        'Status encuesta' => 15,
                    }),
                    self.fetchUsers('principal'),
                    principalsSetter
                )
                #"

                # - Principals/Teachers responses sheet
                #"
                respCountSetter = -> (s) {
                    [
                        s.province_name, #region
                        s.state_name, #depto
                        s.city_name, #municipio
                        s.inep_code, #codigo
                        s.name,
                        s.responses_count,
                    ]
                }
                respHeaders = baseHeaders.merge({
                    'Cantidad de registros de encuesta' => 12,
                })
                self.xlsFillSheet(
                    sheetPrincipalsThatAnswered,
                    respHeaders,
                    self.fetchResposesCount('principal', allSchools),
                    respCountSetter
                )
                self.xlsFillSheet(
                    sheetTeachersThatAnswered,
                    respHeaders,
                    self.fetchResposesCount('teacher', allSchools),
                    respCountSetter
                )
                #"

                # - Teachers sheet
                #"
                teachersSetter = -> (s) { 
                    #Can be NULL
                    resp = SurveyResponse.find_by(
                        :user_id => s._id
                    )
                    [
                        s.school.province_name, #region
                        s.school.state_name, #depto
                        s.school.city_name, #municipio
                        s.school.inep_code, #codigo
                        s.school.name,
                        s.cpf,
                        s.name,
                        s.email,
                        resp&.submitted_at&.strftime(dateFormat),
                        resp&.status,
                    ]
                }
                self.xlsFillSheet(
                    sheetTeachers,
                    baseHeaders.merge({
                        'Cédula de docente' => 25,
                        'Nombre de docente' => 45,
                        'E-mail' => 45,
                        'Fecha digitación de encuesta' => 25,
                        'Status encuesta' => 15,
                    }),
                    self.fetchUsers('teacher'),
                    teachersSetter
                )
    
                #Write to Stream
                file = StringIO.new
                book.write(file)

                #Output file
                filename = "Reporte de Seguimiento - #{Date.today}.xls"

                #Send to browser
                respond_to do |format|
                    format.xls { send_data file.string.force_encoding('binary'), filename: filename }
                end 
            end

            def fetchSchools
                School.all.order(
                    :province_name.asc,
                    :state_name.asc,
                    :city_name.asc,
                    :name.asc,
                )
            end

            def fetchUsers(profile)
                User.where(
                    :_profile => profile
                ).order(
                    :'school.province_name'.asc,
                    :'school.state_name'.asc,
                    :'school.city_name'.asc,
                    :'school.name'.asc,
                )
            end

            def fetchResposesCount(profile, allSchools)

                allSchools.map do |s|
                    resp = SurveyResponse.collection.aggregate([
                        {
                            "$match" => {
                                :'school_id' => s._id
                            }
                        },
                        {
                            "$lookup" => {
                                :from => "users",
                                :localField => "user_id",
                                :foreignField => "_id",
                                :as => "user"
                            }
                        },
                        {
                            "$match" => {
                                :'user._profile' => profile
                            }
                        },
                    ])

                    completedResp = resp.filter{ |o| o["status"] == "Complete" }
                    s.attributes["responses_count"] = completedResp.length()
                    
                    s #return
                end

            end

            def xlsFillSheet(sheet, headers, data, rowSetter)
                sheet.row(0).default_format = Spreadsheet::Format.new(
                    weight: :bold,
                    horizontal_align: :center,
                    bottom: :medium,
                    locked: true
                )
                
                headers.each_with_index do |(text, width), i|
                    sheet.row(0).push text
                    sheet.column(i).width = width
                end

                data.each_with_index do |s, i|
                    sheet.row(i + 1).concat rowSetter.call(s)
                end

                sheet
            end

        end 
    end
end