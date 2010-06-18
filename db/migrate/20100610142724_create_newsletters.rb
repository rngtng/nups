class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
      
      t.string :subject
      t.text :content
      t.text :attachemnts
      
      t.integer :mode,  :null => false, :default => 0
      t.integer :status,  :null => false, :default => 0
      t.integer :last_sent_id
      
      t.integer :recipients_count,  :null => false, :default => 0
      t.integer :deliveries_count,  :null => false, :default => 0
      t.integer :errors_count,  :null => false, :default => 0
      
      t.timestamp :deliver_at
      t.timestamp :delivery_started_at
      t.timestamp :delivery_ended_at
      
      t.belongs_to :account
      
      t.timestamps
    end
    
    add_index :newsletters, [:account_id]
  end

  def self.down
    drop_table :newsletters
  end
end
