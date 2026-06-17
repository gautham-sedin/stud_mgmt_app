require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should redirect index when not logged in" do
    get users_path
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should get index when logged in as admin" do
    sign_in users(:admin)
    get users_path
    assert_response :success
  end

  test "should not get index when logged in as teacher" do
    sign_in users(:teacher)
    get users_path
    # Depending on how your require_admin! method handles failures, 
    # this might be a redirect or a forbidden response. 
    # Usually it redirects to root_path
    assert_response :redirect 
    assert_redirected_to root_path
  end
end
