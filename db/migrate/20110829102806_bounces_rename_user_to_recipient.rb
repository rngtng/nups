class BouncesRenameUserToRecipient < ActiveRecord::Migration
  def change
    rename_column :bounces, :user_id, :recipient_id
    add_column :bounces, :diagnostic_code, :string
  end
end
