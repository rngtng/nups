class AddIndexToSendOuts < ActiveRecord::Migration
  def change
    add_index :send_outs, [:newsletter_id, :type, :recipient_id]
  end
end
