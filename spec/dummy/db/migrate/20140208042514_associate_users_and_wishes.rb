class AssociateUsersAndWishes < ActiveRecord::Migration
  def change
    add_column :wishes, :user_id, :integer
  end
end
