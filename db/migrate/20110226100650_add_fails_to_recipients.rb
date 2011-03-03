class AddFailsToRecipients < ActiveRecord::Migration
  def self.up
    add_column :recipients, :fails_count, :integer, :null => false, :default => 0
    add_column :recipients, :fails, :text, :null => false, :default => ''
    change_column :recipients, :bounces, :text, :null => false, :default => ''
  end

  def self.down
    remove_column :recipients, :fails_count
    remove_column :recipients, :fails
  end
end
