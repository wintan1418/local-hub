require "test_helper"

class Provider::QuotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = User.create!(email: "quote-provider@example.com", password: "password123", user_role: :provider)
    @other_provider = User.create!(email: "other-quote-provider@example.com", password: "password123", user_role: :provider)
    @customer = User.create!(email: "quote-customer@example.com", password: "password123", user_role: :customer)
    @category = Category.create!(name: "Electrical", slug: "electrical")
    @service = create_service(@provider, "Outlet repair")
    @other_service = create_service(@other_provider, "Panel upgrade")
    sign_in @provider, scope: :user
  end

  test "create rejects service ids not owned by current provider" do
    assert_no_difference "Quote.count" do
      post provider_quotes_path, params: {
        quote: {
          service_id: @other_service.id,
          customer_id: @customer.id,
          title: "Unsafe quote",
          description: "Should not save",
          total_price: 100
        }
      }
    end

    assert_redirected_to provider_quotes_path
  end

  test "create accepts service owned by current provider" do
    assert_difference "Quote.count", 1 do
      post provider_quotes_path, params: {
        quote: {
          service_id: @service.id,
          customer_id: @customer.id,
          title: "Safe quote",
          description: "Should save",
          total_price: 100
        }
      }
    end

    assert_equal @service, Quote.order(:created_at).last.service
  end

  private

  def create_service(provider, title)
    Service.create!(
      provider: provider,
      category: @category,
      title: title,
      description: title,
      price_type: :fixed,
      base_price: 75
    )
  end
end
