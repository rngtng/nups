class AddAttributesToAccount < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.column :color, :string, :default => "#FFF"
      t.column :has_html, :boolean, :default => true
      t.column :has_text, :boolean, :default => true
    end
  end
end