require "test_helper"

class RoutesTest < ActionDispatch::IntegrationTest
  EXPECTED_ERROR = {
    "success" => false,
    "error" => {
      "message" => "The requested endpoint does not exist."
    }
  }.freeze

  %i[get post put patch delete].each do |http_method|
    test "returns 404 json for unknown #{http_method.upcase} route" do
      public_send(http_method, "/unknown-route")

      assert_response :not_found
      assert_equal EXPECTED_ERROR, JSON.parse(response.body)
    end
  end
end
