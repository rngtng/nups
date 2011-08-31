class AddSmtpConfigToAccounts < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.remove :host
      t.text :mail_config_raw
    end
  end
end
