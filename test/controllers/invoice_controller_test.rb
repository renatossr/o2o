require "test_helper"

class InvoiceControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get invoice_index_url
    assert_response :success
  end

  test "should get create" do
    get invoice_create_url
    assert_response :success
  end

  test "should get new" do
    get invoice_new_url
    assert_response :success
  end

  test "should get edit" do
    get invoice_edit_url
    assert_response :success
  end

  test "should get show" do
    get invoice_show_url
    assert_response :success
  end

  test "should get update" do
    get invoice_update_url
    assert_response :success
  end

  test "should get destroy" do
    get invoice_destroy_url
    assert_response :success
  end

  test "should get cancel" do
    get invoice_cancel_url
    assert_response :success
  end

  test "should get confirm" do
    get invoice_confirm_url
    assert_response :success
  end
end
