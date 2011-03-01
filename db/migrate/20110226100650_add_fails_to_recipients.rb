class AddFailsToRecipients < ActiveRecord::Migration
  def self.up
    add_column :recipients, :fails_count, :string
    add_column :recipients, :fails, :text
  end

  def self.down
    remove_column :recipients, :fails_count, :string
    remove_column :recipients, :fails
  end
end
