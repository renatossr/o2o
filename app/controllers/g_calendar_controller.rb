class GCalendarController < ApplicationController
  def index
  end

  def redirect
    redirect_to GCalendar.authorization_uri(callback_url).to_s, allow_other_host: true
  end

  def callback
    GCalendar.fetch_access_token(params[:code])
    redirect_to admin_url, notice: "Autenticação realizada com sucesso."
  end

  def events
    GCalendar.syncEvents(additive: true)
    redirect_to admin_url, notice: "Eventos sincronizados com sucesso!"
  end

  def eventsFullSync
    GCalendar.syncEvents(additive: false)
    redirect_to admin_url, notice: "Eventos sincronizados com sucesso!"
  end
end
