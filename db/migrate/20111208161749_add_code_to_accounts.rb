class AddCodeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :permalink, :string
  end
end
