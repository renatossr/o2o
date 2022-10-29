class GCalendarController < ApplicationController
  def index
  end

  def redirect
    get_new_authentication
  end

  def callback
    client = Signet::OAuth2::Client.new(client_options)
    client.code = params[:code]
    response = client.fetch_access_token!
    GToken.store_access_token(response["access_token"])
    GToken.store_refresh_token(response["refresh_token"])
    redirect_to admin_url, notice: "Autenticação realizada com sucesso."
  end

  def events
    syncEvents(additive: true)
  end

  def eventsFullSync
    syncEvents(additive: false)
  end

  private

  def get_new_authentication
    client = Signet::OAuth2::Client.new(client_options)
    redirect_to client.authorization_uri.to_s, allow_other_host: true
  end

  def syncEvents(additive: true)
    client = Signet::OAuth2::Client.new(client_options)
    client.access_token = GToken.get_access_token
    client.update!

    service = Google::Apis::CalendarV3::CalendarService.new
    begin
      service.authorization = client
      service.list_calendar_lists
    rescue Google::Apis::AuthorizationError, Signet::AuthorizationError
      client.refresh_token = GToken.get_refresh_token
      response = client.refresh!
      GToken.store_access_token(response["access_token"])
      service.authorization = client
    end

    events = []
    pageToken = ""
    syncToken = SyncToken.last.token unless SyncToken.last.blank?

    begin
      if additive
        eventList = service.list_events(Rails.application.config.default_calendar, max_results: 500, sync_token: syncToken, page_token: pageToken)
      else #Full Sync
        eventList = service.list_events(Rails.application.config.default_calendar, max_results: 500, page_token: pageToken, time_min: (DateTime.current - 6.months))
      end

      pageToken = eventList.next_page_token
      syncToken = eventList.next_sync_token
      events += eventList.items
    end while (!pageToken.blank?)

    SyncToken.create(token: syncToken)
    processEvents(events)
  end

  def processEvents(events)
    events.each do |event|
      next if (event.start.nil? || event.start.date_time.nil? || event.summary.nil?) && event.status != "cancelled"

      calendarEvent = CalendarEvent.find_by(external_id: event.id, ical_id: event.i_cal_uid)
      calendarEvent = CalendarEvent.find_by(external_id: event.id) if event.i_cal_uid.blank?
      calendarEvent = CalendarEvent.new if calendarEvent.nil?

      calendarEvent.external_id = event.id
      calendarEvent.ical_id = event.i_cal_uid
      calendarEvent.title = event.summary
      calendarEvent.status = event.status
      calendarEvent.external_url = event.html_link
      calendarEvent.description = event.description
      calendarEvent.location = event.location
      calendarEvent.start_at = event.start.date_time unless event.start.blank?
      calendarEvent.end_at = event.end.date_time unless event.end.blank?
      calendarEvent.color_id = event.color_id
      calendarEvent.processed = false

      calendarEvent.status == "cancelled" ? calendarEvent.destroy! : calendarEvent.save!
    end

    redirect_to admin_url, notice: "Eventos sincronizados com sucesso!"
  end

  def client_options
    {
      client_id: Rails.application.credentials.google.client_id,
      client_secret: Rails.application.credentials.google.client_secret,
      authorization_uri: "https://accounts.google.com/o/oauth2/auth",
      token_credential_uri: "https://accounts.google.com/o/oauth2/token",
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: callback_url,
      additional_parameters: {
        "access_type" => "offline",
      },
    }
  end
end
