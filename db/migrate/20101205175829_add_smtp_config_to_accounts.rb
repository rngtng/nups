class AddSmtpConfigToAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.remove :host
      t.text :mail_config_raw
    end    
  end

  def self.down
    change_table :accounts do |t|
      t.remove :mail_config_raw
      t.string :host
    end
  end
end
