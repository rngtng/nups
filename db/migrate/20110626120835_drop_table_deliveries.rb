class DropTableDeliveries < ActiveRecord::Migration
  def up
    drop_table :deliveries
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
