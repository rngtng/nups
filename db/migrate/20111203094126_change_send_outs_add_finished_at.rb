class ChangeSendOutsAddFinishedAt < ActiveRecord::Migration
  def change
    add_column :send_outs, :finished_at, :datetime
  end
end
