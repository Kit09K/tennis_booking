require "test_helper"

class CordsControllerTest < ActionDispatch::IntegrationTest
  test "should get Cords" do
    get cords_Cords_url
    assert_response :success
  end

  test "should get index" do
    get cords_index_url
    assert_response :success
  end
end
