class AddStateToNewsletter < ActiveRecord::Migration
  def change
    change_table :newsletters do |t|
      t.string :state, :default => 'finished'
    end
  end
end
