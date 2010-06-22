class AddAttributesToAccount < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.column :color, :string, :default => "#FFF"
      t.column :has_html, :boolean, :default => true
      t.column :has_text, :boolean, :default => true
    end
  end

  def self.down
    change_table :accounts do |t|
      t.remove :color
      t.remove :has_html
      t.remove :has_text
    end
  end
end