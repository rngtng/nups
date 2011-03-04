class AddFailsToRecipients < ActiveRecord::Migration
  def self.up
    add_column    :recipients, :failed_deliveries_count, :integer, :null => false, :default => 0
    rename_column :recipients, :bounces_count, :bounced_deliveries_count
    remove_column :recipients, :bounces
  end

  def self.down
    add_column :recipients, :bounces, :text, :null => false, :default => ''
    rename_column :recipients, :bounced_deliveries_count, :bounces_count
    remove_column :recipients, :failed_deliveries_count
  end
end
