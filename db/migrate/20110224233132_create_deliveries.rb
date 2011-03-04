class CreateDeliveries < ActiveRecord::Migration
  def self.up
    create_table :deliveries do |t|
      t.string :type

      t.belongs_to :sending
      t.belongs_to :recipient

      t.string :code
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :deliveries
  end
end
