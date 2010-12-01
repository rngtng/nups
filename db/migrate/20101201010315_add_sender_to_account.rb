class AddSenderToAccount < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.string :sender
    end
    
  end

  def self.down
    change_table :accounts do |t|
      t.remove :sender
    end    
  end
end
