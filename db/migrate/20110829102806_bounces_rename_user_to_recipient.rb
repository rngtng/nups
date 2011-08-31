class BouncesRenameUserToRecipient < ActiveRecord::Migration
  def change
    rename_column :bounces, :user_id, :recipient_id
    add_column :bounces, :error_status, :string
    add_column :bounces, :send_out_id, :integer
  end
end
