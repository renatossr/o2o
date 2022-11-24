require "test_helper"

class ItemsImportControllerTest < ActionDispatch::IntegrationTest
  test "should get import_members" do
    get items_import_import_members_url
    assert_response :success
  end

  test "should get import_coaches" do
    get items_import_import_coaches_url
    assert_response :success
  end
end
