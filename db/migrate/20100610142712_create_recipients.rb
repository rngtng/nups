class CreateRecipients < ActiveRecord::Migration
  def self.up
    create_table :recipients do |t|
      t.string :gender
      t.string :first_name
      t.string :last_name
      t.string :email
      
      #t.integer :deliveries_count
      
      t.belongs_to :account
      
      t.timestamps
    end
    
    add_index :recipients, [:id, :account_id], :unique => true
    add_index :recipients, :email
  end

  def self.down
    drop_table :recipients
  end
end
