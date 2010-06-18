class AddDefaultValuesToNewsletter < ActiveRecord::Migration
  def self.up
    change_column :newsletters, :mode, :integer,  :null => false
    change_column :newsletters, :status, :integer,  :null => false
    change_column :newsletters, :last_sent_id, :integer,  :null => false
    change_column :newsletters, :recipients_count, :integer,  :null => false
    change_column :newsletters, :deliveries_count, :integer,  :null => false
    change_column :newsletters, :errors_count, :integer,  :null => false
  end

  def self.down
    change_column :newsletters, :mode, :integer,  :null => true
    change_column :newsletters, :status, :integer,  :null => true
    change_column :newsletters, :last_sent_id, :integer,  :null => true
    change_column :newsletters, :recipients_count, :integer,  :null => true
    change_column :newsletters, :deliveries_count, :integer,  :null => true
    change_column :newsletters, :errors_count, :integer,  :null => true
  end
end