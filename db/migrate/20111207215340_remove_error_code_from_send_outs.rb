class RemoveErrorCodeFromSendOuts < ActiveRecord::Migration
  def up
    remove_column :send_outs, :error_code
  end

  def down
    add_column :send_outs, :error_code, :integer
  end
end
