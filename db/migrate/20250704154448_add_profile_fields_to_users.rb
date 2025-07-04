class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :bio, :text
    add_column :users, :address, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zip_code, :string
    add_column :users, :business_name, :string
    add_column :users, :business_license, :string
    add_column :users, :insurance_number, :string
    add_column :users, :years_experience, :integer
    add_column :users, :verified, :boolean, default: false
    add_column :users, :verified_at, :datetime
  end
end
