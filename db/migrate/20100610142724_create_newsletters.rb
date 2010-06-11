class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
      
      t.string :subject
      t.text :content
      t.text :attachemnts
      
      t.string :mode
      t.string :status
      t.integer :last_sent_id
      
      t.integer :recipients_count
      t.integer :deliveries_count
      t.integer :errors_count
      
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
