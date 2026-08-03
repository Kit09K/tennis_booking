require "test_helper"

class TopupsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get topups_new_url
    assert_response :success
  end

  test "should get create" do
    get topups_create_url
    assert_response :success
  end
end
