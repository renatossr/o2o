class GCalendarController < ApplicationController
  
  def index
  end

  def redirect
    client = Signet::OAuth2::Client.new(client_options)
    redirect_to client.authorization_uri.to_s, allow_other_host: true 
  end

  def callback
    client = Signet::OAuth2::Client.new(client_options)
    client.code = params[:code]
    response = client.fetch_access_token!
    session[:authorization] = response
    redirect_to admin_url, notice: "Autenticação realizada com sucesso."
  end

  def calendars
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    @calendar_list = service.list_calendar_lists
  end

  def events
    syncEvents(additive: true)
  end

  def eventsFullSync
    syncEvents(additive: false)
  end
  

  private

  def syncEvents(additive: true)
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    response = client.refresh!
    session[:authorization] = session[:authorization].merge(response)

    events = []
    pageToken = ''
    syncToken = additive ? SyncToken.last.token : ''

    begin
      eventList = service.list_events(Rails.application.config.default_calendar, max_results: 500, sync_token: syncToken, page_token: pageToken)
      pageToken = eventList.next_page_token
      syncToken = eventList.next_sync_token
      events += eventList.items
    end while (!pageToken.blank?)

    SyncToken.create(token: syncToken)
    processEvents(events)
  end

  def processEvents(events)
    events.each do |event|
      calendarEvent = CalendarEvent.find_by(external_id: event.id)
      if calendarEvent.nil?
        calendarEvent = CalendarEvent.new(
          external_id: event.id,
          title: event.summary,
          status: event.status,
          external_url: event.html_link,
          description: event.description,
          location: event.location,
          start_at: event.start.nil? ? '' : event.start.date_time,
          end_at: event.end.nil? ? '' : event.end.date_time
        )
      else
        calendarEvent.title = event.summary
        calendarEvent.status = event.status
        calendarEvent.external_url = event.html_link
        calendarEvent.description = event.description
        calendarEvent.location = event.location
        calendarEvent.start_at = event.start.nil? ? '' : event.start.date_time
        calendarEvent.end_at = event.end.nil? ? '' : event.end.date_time
      end

      calendarEvent.save!()
    end

    redirect_to admin_url, notice: "Eventos sincronizados com sucesso!"
  end

  def client_options
    {
      client_id: Rails.application.credentials.google.client_id,
      client_secret: Rails.application.credentials.google.client_secret,
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: callback_url
    }
  end
end
