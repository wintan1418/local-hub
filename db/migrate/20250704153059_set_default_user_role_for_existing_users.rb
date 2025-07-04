class SetDefaultUserRoleForExistingUsers < ActiveRecord::Migration[8.0]
  def up
    # Set default role for existing users who have nil user_role
    User.where(user_role: nil).update_all(user_role: :customer)
  end

  def down
    # This migration cannot be safely reversed
  end
end
