class RemoveBouncesFromRecipients < ActiveRecord::Migration
  def up
    remove_column :recipients, :bounces
  end

  def down
    add_column :recipients, :bounces, :text
  end
end
