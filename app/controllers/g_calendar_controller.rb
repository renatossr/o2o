class GCalendarController < ApplicationController
  def index
    authorize GCalendar
  end

  def redirect
    authorize GCalendar
    redirect_to GCalendar.authorization_uri(callback_url).to_s, allow_other_host: true
  end

  def callback
    authorize GCalendar
    GCalendar.fetch_access_token(params[:code])
    flash[:success] = "Autenticação realizada com sucesso."
    redirect_to settings_path
  end

  def events
    authorize GCalendar
    GCalendar.syncEvents(additive: true)
    flash[:success] = "Eventos sincronizados com sucesso!"
    redirect_to settings_path
  end

  def eventsFullSync
    authorize GCalendar
    GCalendar.syncEvents(additive: false)
    flash[:success] = "Eventos sincronizados com sucesso!"
    redirect_to settings_path
  end
end
