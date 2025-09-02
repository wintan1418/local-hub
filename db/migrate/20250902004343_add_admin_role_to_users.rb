class AddAdminRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :admin_role, :string, default: nil
    add_index :users, :admin_role
  end
end
