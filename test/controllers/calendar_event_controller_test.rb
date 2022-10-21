require "test_helper"

class CalendarEventControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get calendar_event_index_url
    assert_response :success
  end

  test "should get process" do
    get calendar_event_process_url
    assert_response :success
  end
end
