class AddStateToRecipients < ActiveRecord::Migration
  def change
    add_column :recipients, :state, :string, :default => 'pending'
    add_column :recipients, :reads_count, :integer, :null => false, :default => 0

    Recipient.update_all(:state => 'confirmed')
  end
end
