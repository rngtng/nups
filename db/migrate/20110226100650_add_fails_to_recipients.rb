class AddFailsToRecipients < ActiveRecord::Migration
  def change
    change_table :recipients do |t|
      t.integer :failed_count, :null => false, :default => 0
    end
  end
end
