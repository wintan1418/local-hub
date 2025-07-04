class ChangePlansFeaturesToJson < ActiveRecord::Migration[8.0]
  def up
    # First convert existing text data to JSON format
    execute <<-SQL
      UPDATE plans 
      SET features = CASE 
        WHEN features IS NULL OR features = '' THEN '[]'::json
        WHEN features LIKE '[%' AND features LIKE '%]' THEN features::json
        ELSE ('["' || replace(features, ',', '","') || '"]')::json
      END
    SQL
    
    # Then change column type
    change_column :plans, :features, :json, using: 'features::json'
  end
  
  def down
    change_column :plans, :features, :text
  end
end
