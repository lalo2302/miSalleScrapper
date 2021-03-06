require 'json'
require 'sinatra/base'
require 'sinatra/activerecord'
require_relative 'formateador'
require_relative 'navegador'
require_relative 'helpers/error_helper'
require_relative 'helpers/login_helper'
require_relative 'controllers/publicidad'
require_relative 'controllers/registro'
Dir["#{Dir.pwd}/app/modelos/*.rb"].each { |file| require file }

class RouterV1 < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :server, 'webrick'

  post '/alumno' do
    @json = JSON.parse(request.body.read)
    @matricula = @json["matricula"].to_i.to_s
    @password = @json["password"]
    @sistema = @json["sistema"]

    if LoginHelper.check_params(@matricula, @password, @sistema) then
      nav = Navegador.new(@matricula, @password, @sistema)
      if nav.login then

        begin
          mapa = nav.parsear
          mapa[:sistema] = @sistema
          info = Formateador::Alumno::V1.formatear(mapa)
          # Fechas de pago en ISO standard (yyyy-MM-dd)
          info[:pagos] = Pago.all
          nuevo_ingreso = RegistroController.registrar_usuario(@matricula, @sistema)
          info[:nuevo_ingreso] = nuevo_ingreso ? 1 : 0
          content_type :json, :charset => 'utf-8'
          info.to_json
        rescue NoMethodError

          status 420
          ErrorHelper.login.to_json
        end

      else
        status 420
        ErrorHelper.login.to_json
      end
    else
      status 460
      ErrorHelper.login.to_json
    end
  end

  post '/creditos' do
    @json = JSON.parse(request.body.read)
    @matricula = @json["matricula"].to_i.to_s
    @password = @json["password"]
    @sistema = @json["sistema"]

    if LoginHelper.check_params(@matricula, @password, @sistema) then
      nav = Navegador.new(@matricula, @password, @sistema)
      if nav.login then
        begin
          creditos = nav.creditos
          info = Formateador::Creditos::V1.formatear(creditos)
          content_type :json, :charset => 'utf-8'
          info.to_json
        rescue NoMethodError
          status 420
          ErrorHelper.login.to_json
        end
      else
        status 420
        ErrorHelper.login.to_json
      end
    else
      status 420
      ErrorHelper.login_to_json
    end
  end

  post '/periodos' do
    @json = JSON.parse(request.body.read)
    @matricula = @json["matricula"].to_i.to_s
    @password = @json["password"]
    @sistema = @json["sistema"]

    if LoginHelper.check_params(@matricula, @password, @sistema) then
      nav = Navegador.new(@matricula, @password, @sistema)
      if nav.login then
        begin
          periodos, info_map = nav.periodos
          info = Formateador::Periodos::V1.formatear(periodos) 
          content_type :json, :charset => 'utf-8'
          info.to_json
        rescue NoMethodError
          status 420
          ErrorHelper.login.to_json
        end
      else
        status 420
        ErrorHelper.login.to_json
      end
    else
      status 460
      ErrorHelper.login.to_json
    end
  end

  post '/anuncio' do
    @json = JSON.parse(request.body.read)
    anuncio = PublicidadController.mostrar_anuncio
    info = Formateador::Anuncio::V1.formatear(anuncio)
    content_type :json, :charset => 'utf-8'
    info.to_json
  end

  post '/click' do
    @json = JSON.parse(request.body.read)
    PublicidadController.registrar_click(@json["campaign_id"], @json["matricula"])
    status 200
    Click.new.to_json
  end

  post '/feedback' do
    @json = JSON.parse(request.body.read)
    @matricula = @json["matricula"]
    @feedback = @json["texto"]
    usuario = Usuario.find_by(matricula: @matricula)
    if usuario != nil then
      feedback = Feedback.new(texto: @feedback, usuario: usuario)
      if feedback.save then
        status 200
        Feedback.new.to_json
      end
    else
      status 470
      ErrorHelper.feedback.to_json
    end
  end
end
