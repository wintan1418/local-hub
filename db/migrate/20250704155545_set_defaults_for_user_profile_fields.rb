class SetDefaultsForUserProfileFields < ActiveRecord::Migration[8.0]
  def change
    change_column_default :users, :years_experience, 0
  end
end
