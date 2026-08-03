require "test_helper"

class Admin::TopupsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_topups_index_url
    assert_response :success
  end

  test "should get update" do
    get admin_topups_update_url
    assert_response :success
  end
end
