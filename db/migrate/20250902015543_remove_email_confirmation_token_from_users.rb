class RemoveEmailConfirmationTokenFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :email_confirmation_token, :string
    remove_index :users, :email_confirmation_token if index_exists?(:users, :email_confirmation_token)
  end
end
