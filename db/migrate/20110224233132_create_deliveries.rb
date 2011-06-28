class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.string :type

      t.belongs_to :sending
      t.belongs_to :recipient

      t.string :code
      t.text :message

      t.timestamps
    end
  end

end
