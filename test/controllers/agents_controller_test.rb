require "test_helper"

class AgentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get agents_index_url
    assert_response :success
  end

  test "should get create" do
    get agents_create_url
    assert_response :success
  end
end
