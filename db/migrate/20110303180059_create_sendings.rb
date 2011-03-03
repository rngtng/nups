class CreateSendings < ActiveRecord::Migration
  def self.up
    create_table :sendings do |t|
      t.string :type
      t.integer :delivery_id
      t.integer :user_id
      t.string :code
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :sendings
  end
end
