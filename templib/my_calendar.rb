
require 'google/api_client/client_secrets'
require 'google/api_client/auth/key_utils'
require 'google/apis/calendar_v3'

class MyCalendarService
  CALENDAR_ID = 'kenji.tachibana@quantum.ne.jp'
  APPLICATION_NAME = 'my_calender'
  SERVICE_ACCOUNT_EMAIL = 'googlecalendar@affable-bivouac-146712.iam.gserviceaccount.com'
  CLIENT_SECRET_PATH = Rails.root.join('.credentials', 'My Project-964eda03d6b4.p12').to_s
  CLIENT_SECRET_PASSWORD = 'notasecret'
  #SCOPES = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY
  SCOPES = Google::Apis::CalendarV3::AUTH_CALENDAR

  def initialize
    build_service
  end

  def list_events
    res = @service.list_events(CALENDAR_ID, max_results: 10, single_events: true, order_by: 'startTime', time_min: Time.now.iso8601)
    res.items.each do |event|
      start = event.start.date || event.start.date_time
      puts "- #{event.summary} (#{start})"
    end
  end

  private

  def build_service
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = APPLICATION_NAME
    key = Google::APIClient::KeyUtils.load_from_pkcs12(CLIENT_SECRET_PATH, CLIENT_SECRET_PASSWORD)
    @service.authorization = Signet::OAuth2::Client.new(
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      audience: 'https://accounts.google.com/o/oauth2/token',
      scope: SCOPES,
      issuer: SERVICE_ACCOUNT_EMAIL,
      signing_key: key
    )
    @service.authorization.fetch_access_token!
  end

end
