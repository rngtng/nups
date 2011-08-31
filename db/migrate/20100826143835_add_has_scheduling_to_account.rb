class AddHasSchedulingToAccount < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.boolean :has_scheduling
    end
  end
end
