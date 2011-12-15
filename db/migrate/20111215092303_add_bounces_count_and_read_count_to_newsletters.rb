class AddBouncesCountAndReadCountToNewsletters < ActiveRecord::Migration
  def change
    add_column :newsletters, :bounces_count, :integer, :null => false, :default => 0
    add_column :newsletters, :reads_count, :integer, :null => false, :default => 0

    rename_column :newsletters, :errors_count, :fails_count
    rename_column :recipients, :failed_count, :fails_count
  end
end
