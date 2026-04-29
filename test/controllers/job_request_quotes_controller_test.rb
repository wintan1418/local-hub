require "test_helper"

class JobRequestQuotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = User.create!(email: "request-customer@example.com", password: "password123", user_role: :customer)
    @provider = User.create!(email: "request-provider@example.com", password: "password123", user_role: :provider)
    @category = Category.create!(name: "Moving", slug: "moving")
    @job_request = JobRequest.create!(
      customer: @customer,
      category: @category,
      title: "Move apartment",
      description: "Need help moving",
      status: :open
    )
    @quote = @job_request.quotes.create!(provider: @provider, price: 300, message: "I can do it", status: :declined)
    sign_in @customer, scope: :user
  end

  test "accept rejects non-pending quote" do
    patch accept_job_request_quote_path(@job_request, @quote)

    assert @quote.reload.declined?
    assert @job_request.reload.open?
    assert_redirected_to job_request_path(@job_request)
  end
end
