class CreateStripePricesForPlans < ActiveRecord::Migration[8.0]
  def up
    # Update existing plans with Stripe price IDs
    # These will be created manually in Stripe or via the Stripe service

    free_plan = Plan.find_by(name: 'Free')
    professional_plan = Plan.find_by(name: 'Professional')
    business_plan = Plan.find_by(name: 'Business')

    if free_plan
      free_plan.update!(stripe_price_id: 'price_free_plan') # Free plans don't need real Stripe price
    end

    # These price IDs will be created via Stripe API or manually
    # For now, we'll use placeholder values that we'll update after creating in Stripe
    if professional_plan
      professional_plan.update!(stripe_price_id: 'price_professional_monthly')
    end

    if business_plan
      business_plan.update!(stripe_price_id: 'price_business_monthly')
    end
  end

  def down
    Plan.update_all(stripe_price_id: nil)
  end
end
