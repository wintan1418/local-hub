namespace :stripe do
  desc "Create Stripe products and prices for subscription plans"
  task setup: :environment do
    puts "🔗 Setting up Stripe products and prices..."
    
    Plan.all.each do |plan|
      next if plan.name == 'Free' # Skip free plan
      
      begin
        # Create product
        product = Stripe::Product.create({
          name: "LocalServiceHub #{plan.name} Plan",
          description: "#{plan.name} subscription plan for service providers",
          metadata: {
            plan_id: plan.id
          }
        })
        
        puts "✅ Created product: #{product.name}"
        
        # Create price
        price = Stripe::Price.create({
          unit_amount: (plan.price * 100).to_i, # Convert to cents
          currency: 'usd',
          recurring: {
            interval: plan.billing_period == 'yearly' ? 'year' : 'month'
          },
          product: product.id,
          metadata: {
            plan_id: plan.id
          }
        })
        
        puts "✅ Created price: $#{plan.price}/#{plan.billing_period} - #{price.id}"
        
        # Update plan with Stripe price ID
        plan.update!(stripe_price_id: price.id)
        puts "✅ Updated plan #{plan.name} with Stripe price ID"
        
      rescue Stripe::StripeError => e
        puts "❌ Error creating Stripe price for #{plan.name}: #{e.message}"
      end
    end
    
    # Set free plan price ID to a placeholder
    free_plan = Plan.find_by(name: 'Free')
    if free_plan && free_plan.stripe_price_id.blank?
      free_plan.update!(stripe_price_id: 'price_free_plan')
      puts "✅ Set free plan price ID"
    end
    
    puts "🎉 Stripe setup completed!"
  end
  
  desc "List all Stripe products and prices"
  task list: :environment do
    puts "📋 Listing Stripe products and prices..."
    
    products = Stripe::Product.list(limit: 100)
    products.data.each do |product|
      puts "\n🏷️  Product: #{product.name} (#{product.id})"
      
      prices = Stripe::Price.list(product: product.id)
      prices.data.each do |price|
        amount = price.unit_amount ? "$#{price.unit_amount / 100.0}" : "Free"
        interval = price.recurring ? "/#{price.recurring.interval}" : ""
        puts "   💰 Price: #{amount}#{interval} (#{price.id})"
      end
    end
  end
end