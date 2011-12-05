class ChangeSendOutsAddFinishedAt < ActiveRecord::Migration
  def change
    add_column :send_outs, :finished_at, :datetime

    # UPDATE `send_outs` SET finished_at = updated_at WHERE `send_outs`.`type` IN ('LiveSendOut') AND (`send_outs`.`state` IN ('finished')) AND finished_at IS NULL
  end
end
