class AddSiteFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :slug, :string
    add_index :users, :slug, unique: true
    add_column :users, :site_theme, :integer, default: 0
    add_column :users, :site_brand_color, :string, default: "#f97316"
    add_column :users, :site_tagline, :string
    add_column :users, :site_about, :text
    add_column :users, :site_published, :boolean, default: false
  end
end
