class Api::SearchSuggestionsController < ApplicationController
  # Public endpoint — no auth needed for browsing
  skip_before_action :verify_authenticity_token, only: [ :index ]

  def index
    q = params[:q].to_s.strip
    if q.length < 2
      render json: { categories: [], services: [], providers: [] }
      return
    end

    pattern = "%#{q}%"

    categories = Category.where("name ILIKE ?", pattern)
                         .order(:name)
                         .limit(4)
                         .map { |c| { id: c.id, name: c.name, slug: c.slug, count: c.services.count } }

    services = Service.includes(:category, :provider)
                      .where("services.title ILIKE ? OR services.description ILIKE ?", pattern, pattern)
                      .order(created_at: :desc)
                      .limit(6)
                      .map { |s|
                        {
                          id: s.id,
                          title: s.title,
                          category_name: s.category&.name,
                          provider_name: s.provider&.display_name,
                          price: s.base_price.to_i,
                          rating: s.provider&.average_rating || 0
                        }
                      }

    providers = User.provider
                    .where("first_name ILIKE ? OR last_name ILIKE ? OR business_name ILIKE ?", pattern, pattern, pattern)
                    .limit(4)
                    .map { |p|
                      {
                        id: p.id,
                        name: p.business_name.presence || p.display_name,
                        rating: p.average_rating,
                        reviews: p.total_reviews
                      }
                    }

    render json: {
      query: q,
      categories: categories,
      services: services,
      providers: providers
    }
  end
end
