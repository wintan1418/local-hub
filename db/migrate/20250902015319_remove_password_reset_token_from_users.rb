class RemovePasswordResetTokenFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :password_reset_token, :string
    remove_index :users, :password_reset_token if index_exists?(:users, :password_reset_token)
  end
end
