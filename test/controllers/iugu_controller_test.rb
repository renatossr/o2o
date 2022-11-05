require "test_helper"

class IuguControllerTest < ActionDispatch::IntegrationTest
  test "should get invoice_status_webhook" do
    get iugu_invoice_status_webhook_url
    assert_response :success
  end
end
