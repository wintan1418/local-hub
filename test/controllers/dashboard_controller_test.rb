require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "dashboard redirects customers to customer dashboard" do
    user = User.create!(
      email: "customer-dashboard@example.com",
      password: "password123",
      user_role: :customer,
      first_name: "Casey",
      last_name: "Customer"
    )
    sign_in user, scope: :user

    get user_dashboard_path

    assert_redirected_to customer_dashboard_path
  end

  test "dashboard redirects providers to provider dashboard" do
    user = User.create!(
      email: "provider-dashboard@example.com",
      password: "password123",
      user_role: :provider,
      first_name: "Pat",
      last_name: "Provider"
    )
    sign_in user, scope: :user

    get user_dashboard_path

    assert_redirected_to provider_dashboard_path
  end
end
