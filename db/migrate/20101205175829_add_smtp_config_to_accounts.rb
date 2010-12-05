class AddSmtpConfigToAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      #t.remove :host
      t.text :mail_config
    end    
  end

  def self.down
    change_table :accounts do |t|
      t.remove :mail_config
      t.string :host
    end
  end
end
