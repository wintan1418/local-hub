require "test_helper"

class RegistrationsSecurityTest < ActionDispatch::IntegrationTest
  test "sign up coerces admin role requests to customer" do
    post user_registration_path, params: {
      user: {
        email: "role-escalation@example.com",
        password: "password123",
        password_confirmation: "password123",
        user_role: "admin"
      }
    }

    user = User.find_by!(email: "role-escalation@example.com")
    assert user.customer?
  end

  test "account update does not change role" do
    user = User.create!(
      email: "role-update@example.com",
      password: "password123",
      user_role: :customer,
      first_name: "Role",
      last_name: "User"
    )
    sign_in user, scope: :user

    patch user_registration_path, params: {
      user: {
        email: user.email,
        current_password: "password123",
        user_role: "admin"
      }
    }

    assert user.reload.customer?
  end
end
