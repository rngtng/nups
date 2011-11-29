class ChangeTableRecipientsAddCode < ActiveRecord::Migration
  def change
     add_column :recipients, :confirm_code, :string
  end
end
