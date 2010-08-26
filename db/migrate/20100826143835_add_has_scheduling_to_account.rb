class AddHasSchedulingToAccount < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.boolean :has_scheduling
    end
    
  end

  def self.down
    change_table :accounts do |t|
      t.remove :has_scheduling
    end    
  end
end
