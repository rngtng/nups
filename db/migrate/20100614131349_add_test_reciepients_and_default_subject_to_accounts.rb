class AddTestReciepientsAndDefaultSubjectToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :subject, :string
    add_column :accounts, :test_recipients, :text
  end

  def self.down
    remove_column :accounts, :subject
    remove_column :accounts, :test_recipients
  end
end