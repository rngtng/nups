class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      
      t.string :name
      t.string :from
      t.string :host
      
      t.belongs_to :user
      
      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
