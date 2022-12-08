class GCalendar
  def self.syncEvents(additive: true)
    client = get_client
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
        eventList = service.list_events(Rails.application.config.default_calendar, single_events: true, max_results: 500, sync_token: syncToken, page_token: pageToken)
      else #Full Sync
        eventList =
          service.list_events(
            Rails.application.config.default_calendar,
            single_events: true,
            max_results: 500,
            page_token: pageToken,
            time_min: (DateTime.current.beginning_of_month),
            time_max: (DateTime.current.end_of_day),
          )
      end

      pageToken = eventList.next_page_token
      syncToken = eventList.next_sync_token
      events += eventList.items
    end while (!pageToken.blank?)

    SyncToken.create(token: syncToken)
    processEvents(events)
  end

  def self.processEvents(events)
    events.each do |event|
      next if (event.start.nil? || event.start.date_time.nil? || event.summary.nil?) && event.status != "cancelled"

      if event.start&.date_time.present?
        calendarEvent = CalendarEvent.find_by(external_id: event.id, ical_id: event.i_cal_uid, start_at: event.start.date_time)
      else
        calendarEvent = CalendarEvent.find_by(external_id: event.id, ical_id: event.i_cal_uid)
      end
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
      calendarEvent.color_id = event.color_id.to_i
      calendarEvent.processed = false

      calendarEvent.status == "cancelled" ? calendarEvent.destroy! : calendarEvent.save!
    end
  end

  def self.get_client
    client = Signet::OAuth2::Client.new(client_options)
  end

  def self.fetch_access_token(code)
    client = get_client
    client.code = code
    response = client.fetch_access_token!
    GToken.store_access_token(response["access_token"])
    GToken.store_refresh_token(response["refresh_token"])
  end

  def self.authorization_uri(callback_url)
    @callback_url = callback_url
    client = get_client
    client.authorization_uri
  end

  private

  def self.client_options
    {
      client_id: Rails.application.credentials.google.client_id,
      client_secret: Rails.application.credentials.google.client_secret,
      authorization_uri: "https://accounts.google.com/o/oauth2/auth",
      token_credential_uri: "https://accounts.google.com/o/oauth2/token",
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: @callback_url,
      additional_parameters: {
        "access_type" => "offline",
      },
    }
  end
end
